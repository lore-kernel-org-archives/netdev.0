From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 5/6] v4 Add RX packet classification interface
Date: Thu, 28 Apr 2011 13:15:25 -0700
Message-ID: <4DB9CADD.9090606@intel.com>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>	 <20110421204040.23054.87188.stgit@gitlad.jf.intel.com> <1303927934.2875.82.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27934 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760271Ab1D1UPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 16:15:41 -0400
In-Reply-To: <1303927934.2875.82.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/2011 11:12 AM, Ben Hutchings wrote:
> On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
[...]
>> +     /* verify only one field is setting data field */
>> +     if ((fsp->flow_type&  FLOW_EXT)&&
>> +         (fsp->m_ext.data[0] || fsp->m_ext.data[1])&&
>> +         fsp->m_ext.vlan_etype)
>> +             return -1;
>> +
>> +     /* initialize entire ntuple to all 0xFF */
>> +     memset(ntuple, ~0, sizeof(*ntuple));
>
> The comment needs to explain *why* the value is ~0 rather than 0.  I
> assume the idea is to set the masks to ~0 if they are not initialised
> below.

This has to do with future compatibility and general setup.  By setting 
all of the values to ~0 the rule is essentially set to mask everything 
and has a default action of drop.

>> +     /* set non-filter values */
>> +     ntuple->flow_type = fsp->flow_type;
>> +     ntuple->action = fsp->ring_cookie;
>> +
>> +     /* copy header portion over */
>> +     memcpy(&ntuple->h_u,&fsp->h_u, sizeof(fsp->h_u));
>
> This deserves a comment that the two h_u fields are different unions,
> but are defined identically except for padding at the end.

I've added a comment similar to that to the code.

>> +     /* copy mask portion over and invert */
>> +     memcpy(&ntuple->m_u,&fsp->m_u, sizeof(fsp->m_u));
>> +     for (i = 0; i<  sizeof(fsp->m_u); i++)
>> +             ntuple->m_u.hdata[i] ^= 0xFF;
>> +
>> +     /* copy extended fields */
>> +     if (fsp->flow_type&  FLOW_EXT) {
>> +             ntuple->vlan_tag =
>> +                     ntohs(fsp->h_ext.vlan_tci);
>> +             ntuple->vlan_tag_mask =
>> +                     ~ntohs(fsp->m_ext.vlan_tci);
>> +             if (fsp->m_ext.vlan_etype) {
>> +                     ntuple->data =
>> +                             ntohl(fsp->h_ext.vlan_etype);
>> +                     ntuple->data_mask =
>> +                             ~(u64)ntohl(fsp->m_ext.vlan_etype);
>> +             } else {
>> +                     ntuple->data =
>> +                             (u64)ntohl(fsp->h_ext.data[0]);
>> +                     ntuple->data |=
>> +                             (u64)ntohl(fsp->h_ext.data[1])<<  32;
>> +                     ntuple->data_mask =
>> +                             (u64)ntohl(~fsp->m_ext.data[0]);
>> +                     ntuple->data_mask |=
>> +                             (u64)ntohl(~fsp->m_ext.data[1])<<  32;
>> +             }
>> +     }
>
> I think it would be clearer to add:
>
>          else {
>                  ntuple->vlan_tag_mask = ~(u16)0;
>                  ntuple->data_mask = ~(u64)0;
>          }
>
> rather than use memset() above.

I thought about doing that, but the advantage of the memset is that it 
covers all of the fields.  So in the unlikely event that someone were to 
add fields in the future to the h_u/m_u sections of the driver this way 
we can guarantee all of the fields that we didn't set are masked.

>> +     return 0;
>> +}
>> +
>>   static int do_srxntuple(int fd, struct ifreq *ifr)
>>   {
>> +     struct ethtool_rx_ntuple ntuplecmd;
>> +     struct ethtool_value eval;
>>        int err;
>>
>> -     if (sntuple_changed) {
>> -             struct ethtool_rx_ntuple ntuplecmd;
>> +     /* verify if Ntuple is supported on the HW */
>
> This comment is inaccurate.

Yeah, it belonged a few lines lower  I think it was left over from some 
earlier work that was there and when I reordered things to do the 
conversion to ntuple first the comment didn't get moved.

>> +     err = flow_spec_to_ntuple(&rx_rule_fs,&ntuplecmd.fs);
>> +     if (err)
>> +             return -1;
>> +
>> +     /*
>> +      * Check to see if the flag is set for N-tuple, this allows
>> +      * us to avoid the possible EINVAL response for the N-tuple
>> +      * flag not being set on the device
>> +      */
>> +     eval.cmd = ETHTOOL_GFLAGS;
>> +     ifr->ifr_data = (caddr_t)&eval;
>> +     err = ioctl(fd, SIOCETHTOOL, ifr);
>> +     if (err || !(eval.data&  ETH_FLAG_NTUPLE))
>> +             return -1;
>>
>> -             ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
>> -             memcpy(&ntuplecmd.fs,&ntuple_fs,
>> -                    sizeof(struct ethtool_rx_ntuple_flow_spec));
>> +     /* send rule via N-tuple */
>> +     ntuplecmd.cmd = ETHTOOL_SRXNTUPLE;
>> +     ifr->ifr_data = (caddr_t)&ntuplecmd;
>> +     err = ioctl(fd, SIOCETHTOOL, ifr);
>>
>> -             ifr->ifr_data = (caddr_t)&ntuplecmd;
>> -             err = ioctl(fd, SIOCETHTOOL, ifr);
>> -             if (err<  0)
>> -                     perror("Cannot add new RX n-tuple filter");
>> +     /*
>> +      * Display error only if reponse is something other than op not
>> +      * supported.  It is possible that the interface uses the network
>> +      * flow classifier interface instead of N-tuple.
>> +      */
>> +     if (err&&  errno != EOPNOTSUPP)
>> +             perror("Cannot add new rule via N-tuple");
>> +
>> +     return err;
>> +}
>> +
>> +static int do_srxclsrule(int fd, struct ifreq *ifr)
>> +{
>> +     int err;
>> +
>> +     if (rx_class_rule_added) {
>> +             /* attempt to add rule via N-tuple specifier */
>> +             err = do_srxntuple(fd, ifr);
>> +             if (!err)
>> +                     return 0;
>> +
>> +             /* attempt to add rule via network flow classifier */
>> +             err = rxclass_rule_ins(fd, ifr,&rx_rule_fs);
>> +             if (err<  0) {
>> +                     fprintf(stderr, "Cannot insert"
>> +                             " classification rule\n");
>> +                     return 1;
>> +             }
>
> Is this the right order to try them?  I'm not sure.

The reason why I chose to do it this way was because it is actually 
fewer steps to try doing an ntuple than it is to do a network flow 
classifier rule.  To fail ntuple I only really need to check the flag, 
whereas for network flow classifier I end up having to go through the 
path that does init for any rule add which is significantly more overhead.

All of the other changes you suggested for this patch I think I have 
implemented for the next version.  I'm working on finishing up the 
updates now.  But I think it will take me a day or to in order to 
sufficient testing so I can be confident all the bugs are worked out 
after the changes.  I'll probably be able to email out the update 
patches on Friday.

Thanks,

Alex
