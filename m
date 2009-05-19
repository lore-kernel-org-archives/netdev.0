From: Claude Robitaille <clauder@accedian.com>
Subject: Re: sk_buff handling in packet handler
Date: Tue, 19 May 2009 18:41:28 -0400
Message-ID: <4A133598.80405@accedian.com>
References: <20090517102548.0a55d5bd.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010204020409070608070803"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:28560 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbZESWlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:41:39 -0400
Received: by yw-out-2324.google.com with SMTP id 5so64889ywb.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 15:41:40 -0700 (PDT)
In-Reply-To: <20090517102548.0a55d5bd.ipng@69706e6720323030352d30312d31340a.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010204020409070608070803
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Thanks Mark, very helpful

But I still  have some questions.

I see that you are using sbk_share_check, which will create a clone if 
the sk_buff is already used by someone else. In most cases the skb is 
not shared and the function simply return the same pointer without any 
modification to the original skb (in particular skb->users stays at 1). 
You  then manipulate the  sk_buff  (in particular  adding a MAC header, 
etc.) and eventually transmit the packet using dev_queue_xmit. The 
sk_buff will be ultimately kfree_skb by the NIC driver (or by you if an 
error occured somewhere before dev_queue_xmit).

My questions are:

- after you are done, net_rx_action may pass the sk_buff, modified by 
ectp_rcv, to other packet handler. How will other packet handlers know 
that, if they need to manipulate the sk_buff, they must create a clone? 
skb->users is still set to 1
- I presume that net_rx_action must also kfree the sk_buff, particularly 
if no packet handler decides to grab the packet. But it should not free 
it if it is still in the transmit queue, waiting for the HW to transmit 
it. But since nothing in the sk_buff tell net_rx_action that the packet 
is pending transmission how could this be the case? dev_queue_xmit does 
not appear to increase users (I used printk in another module to check 
this before and after calling dev_queue_xmit but it might be that my 
idle system is too fast for the printk to catch skb->users going to 2). 
In any case, I try to use sk_get (and 1 x kfree_skb) in my packet 
handler but I end up consuming all the memory in the system, presumably 
due to the fact that the sk_buff never get freed completely. What should 
be the correct way of handling this?

Claude

Mark Smith wrote:
> Hi Claude,
>
> You could have a look at my Ethernet Configuration Testing Protocol
> (ECTP) implementation. I followed what other protocols did regarding
> packet/skb handling, and also tried to make it very clear what was
> required, as I struggled a bit with similar issues that you are. The
> routine to start with is ectp_rcv().
>
> http://lwn.net/Articles/330797/
>
> Regards,
> Mark.
>
>   

-- 
Claude Robitaille
CTO
Accedian Networks
514-764-0119
clauder@accedian.com


--------------010204020409070608070803
Content-Type: text/x-vcard; charset=utf-8;
 name="clauder.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="clauder.vcf"

begin:vcard
fn:Claude Robitaille
n:Robitaille;Claude
email;internet:clauder@accedian.com
tel;work:514-764-0119
tel;cell:514-796-7225
x-mozilla-html:TRUE
version:2.1
end:vcard


--------------010204020409070608070803--
