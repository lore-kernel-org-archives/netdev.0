From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv3 net] i40e: Implement ndo_gso_check()
Date: Thu, 4 Dec 2014 13:15:30 -0800
Message-ID: <CANr6G5yNXXnoTJ3ciEmFRyw8t_phJW-T3XJBvw=FXzkO5ERruQ@mail.gmail.com>
References: <1417718366-14310-1-git-send-email-joestringer@nicira.com> <CA+mtBx_BiJ526jop1tLhx1ji4beRufQRhiN9nfFBWLnr25DMww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"linux.nics" <linux.nics@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog038.obsmtp.com ([74.125.150.112]:52533 "HELO
	na6sys009bog038.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932854AbaLDVP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 16:15:56 -0500
Received: by mail-wg0-f43.google.com with SMTP id l18so23943714wgh.16
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 13:15:50 -0800 (PST)
In-Reply-To: <CA+mtBx_BiJ526jop1tLhx1ji4beRufQRhiN9nfFBWLnr25DMww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 December 2014 at 12:17, Tom Herbert <therbert@google.com> wrote:
> On Thu, Dec 4, 2014 at 10:39 AM, Joe Stringer <joestringer@nicira.com> wrote:
>> ndo_gso_check() was recently introduced to allow NICs to report the
>> offloading support that they have on a per-skb basis. Add an
>> implementation for this driver which checks for IPIP, GRE, UDP tunnels.
>>
>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>> ---
>> v3: Drop IPIP and GRE (no driver support even though hw supports it).
>>     Check for UDP outer protocol for UDP tunnels.
>> v2: Expand to include IP in IP and IPv4/IPv6 inside GRE/UDP tunnels.
>>     Add MAX_INNER_LENGTH (as 80).
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e_main.c |   26 ++++++++++++++++++++++++++
>>  1 file changed, 26 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index c3a7f4a..0d6493a 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -7447,6 +7447,31 @@ static int i40e_ndo_fdb_dump(struct sk_buff *skb,
>>
>>  #endif /* USE_DEFAULT_FDB_DEL_DUMP */
>>  #endif /* HAVE_FDB_OPS */
>> +static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev)
>> +{
>> +       if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) {
>> +               unsigned char *ihdr;
>> +
>> +               if (skb->protocol != IPPROTO_UDP ||
>> +                   skb->inner_protocol_type != ENCAP_TYPE_ETHER)
>> +                       return false;
>> +
>> +               if (skb->inner_protocol == htons(ETH_P_TEB))
>> +                       ihdr = skb_inner_mac_header(skb);
>> +               else if (skb->inner_protocol == htons(ETH_P_IP) ||
>> +                        skb->inner_protocol == htons(ETH_P_IPV6))
>> +                       ihdr = skb_inner_network_header(skb);
>> +               else
>> +                       return false;
>> +
>
> Wow, this is getting complicated! :-( It's not clear that the protocol
> specific checks are needed here since it looks like the header length
> is being passed to the device later on. Also, I think we need
> skb_inner_mac_header(skb) - skb_transport_header(skb) to always work
> to give the length of the encapsulation headers (in case there is no
> real inner mac header, then that offset should be for the network
> header).
>
> So would a simple check like this work:
>
> if (skb->encapsulation &&
>     (skb_inner_mac_header(skb) - skb_transport_header(skb)) >
> MAX_TUNNEL_HDR_LEN)
>        return false;

Ah, I didn't realise that the inner_mac_header() would be equivalent
to inner network when inner mac doesn't exist. This is much tidier,
thanks Tom.
