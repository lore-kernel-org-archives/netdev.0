From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net-next] vxlan: Advertise SCTP checksum offloads
Date: Thu, 01 May 2014 13:09:05 +0200
Message-ID: <53622B51.5000901@redhat.com>
References: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com> <1398775161.3881.9.camel@deadeye.wl.decadent.org.uk> <C5551D9AAB213A418B7FD5E4A6F30A0784A4DA91@ORSMSX108.amr.corp.intel.com> <535FDCE0.80803@gmail.com> <alpine.LFD.2.11.1404291028470.14497@fvl-a0.jf.intel.com> <535FE8D5.90600@gmail.com> <alpine.LFD.2.03.1404291210400.19571@intel.com> <535FFCA5.2080707@gmail.com> <alpine.LFD.2.03.1404291357500.27339@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752409AbaEALJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 07:09:22 -0400
In-Reply-To: <alpine.LFD.2.03.1404291357500.27339@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2014 10:59 PM, Joseph Gasparakis wrote:
> On Tue, 29 Apr 2014, Vlad Yasevich wrote:
...
>>>>>> At the time SCTP tries to do checksum, it will see hw offload
>>>>>> support and set checksum as partial.  That will be propagated
>>>>>> all the way to vxlan which will set encapsulation and pass it on.
>>>>>> At next dev_hard_start_xmit(), we'll look at hw_enc_features,
>>>>>> but it won't matter since SCTP packets are never GSO.
>>>>>>
>>>>>> So, we'll use the non-gso code path and still send with partial
>>>>>> checksum set.  Now, if the driver supports encapsulated SCTP,
>>>>>> then it will work.  If it doesn't, the udp checksum will be computed,
>>>>>> but not the sctp one.
>>>>>
>>>>> That is exactly the way it works, dev_hard_start_xmit() is where
>>>>> the (inner) unchecksummed packets will get checksummed if the Tx'ing
>>>>> interface does not support inner SCTP checksumming.
>>>>
>>>> No, it will not.  dev_hard_start_xmit() calls skb_checksum_help()
>>>> which only knows how to calculate TCP/UDP checksums.  It doesn't know
>>>> how to compute CRC32c for SCTP protocol.
>>>
>>> Interesting, thanks for the clarification! Then how do things work with
>>> non-encapsulated SCTP traffic? Where is the csumming for SCTP take place
>>> if the NIC cannot offload the protocol?
>>
>> In SCTP itself.  Look at sctp_packet_transmit().   There are also
>> fix-ups in netfilter to correct the checksum if the packet has
>> to be rerouted somewhere else.
>>
>> We've tossed around the idea of making skb_checksum have pluggable
>> components.  Daniel started us down that path by adding checksum ops.
>> We just need registration and proper lookup support.

Absolutely, Vlad is right here. That's also why we currently have this
ugly xfrm test in SCTP output path for csumming. I've started something
a while ago in that direction but got distracted with other things. If
someone is faster than me, I appreciate it. ;) In case not, I've kept
it on my todo list so far. Anyway, that would be the right way to go.
