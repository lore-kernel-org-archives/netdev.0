From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bug 15703] New: Getting "MD5 Hash failed for" for fragmented
 IP packets.
Date: Wed, 7 Apr 2010 09:28:22 -0700
Message-ID: <20100407092822.39f6ea2a@nehalam>
References: <bug-15703-100@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bugzilla-daemon@bugzilla.kernel.org, vishal.swarnkar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60170 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753535Ab0DGQ3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 12:29:13 -0400
In-Reply-To: <bug-15703-100@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 Apr 2010 09:52:46 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=15703
> 
>            Summary: Getting "MD5 Hash failed for" for fragmented IP
>                     packets.
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31-14-generic
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: vishal.swarnkar@gmail.com
>                 CC: vishal.swarnkar@gmail.com
>         Regression: No
> 
> 
> I am using Ubuntu 9.10 with a kernel 2.6.31-14-generic.
> 
> At my linux box I am receiving IP packets with TCP as payload with TCP-MD5
> option as its a BGP update.
> 
> If I am getting fragmented IP packets on my Linux box then I am receiving only
> one fragment of the IP packet and I don't receive the second fragments because
> of some settings at my firewall ( I discard small packets, and the second
> fragment has only 20 bytes of data, so I consider it as small packet and always
> discard it).
> 
> I have ensured that I am not receiving the second fragment of the packet all
> the time ( in all further retransmission ) using sniffers.
> 
> Now for a IP fragmented packet I keep on getting messages 
> "MD5 hash failed for IP(src)--> IP(Dst)". I receive this message for all
> fragmented packets. The message is in tcp_ipv4.c - >tcp_v4_inbound_md5_hash
> method.
> 
> I hope I should not be getting these message because the fragmented packets
> should not be pushed to the upper layer( TCP) for further sanity checks(
> MD5-check sum verification), until all fragments are assembled together.
> 
> I tried to look at the ip_rcv code and found that ip_local_deliver(struct
> sk_buff* skb) is calling ip_defrag() function to check if the fragmentation
> task is still in progress or not.
> 
> I tried to dig down more into ip_defrag function and the return values from
> ip_defrag function and I hope that the check in the ip_local_deliver function
> is not correct.
> 
> int ip_local_deliver(struct sk_buff *skb)
> {
>     /*
>      *    Reassemble IP fragments.
>      */
> 
>     if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
>         if (ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER))
>             return 0;
>     }
> 
>     return NF_HOOK(PF_INET, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
>                ip_local_deliver_finish);
> }
> 
> 
> I think the check for ip_defrag should be like this 
> ------>>>>if (ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER) < 0) 
> 
> we should check the negative return to avoid ip_local_deliver_finish, instead
> of checking the null return.

Maybe path MTU discovery can help with this.
