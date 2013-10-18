From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Neterion and UFO handling [was: Re: [PATCH] ipv6: udp packets
 following an UFO enqueued packet need also be handled by UFO]
Date: Fri, 18 Oct 2013 09:52:48 +0200
Message-ID: <20131018075248.GA1491@minipsycho.orion>
References: <20131001232534.GM10771@order.stressinduktion.org>
 <20131002085842.GA1528@minipsycho.brq.redhat.com>
 <1380710488.19002.67.camel@edumazet-glaptop.roam.corp.google.com>
 <20131002121207.GO10771@order.stressinduktion.org>
 <20131002130329.GP10771@order.stressinduktion.org>
 <1380726867.19002.104.camel@edumazet-glaptop.roam.corp.google.com>
 <20131002162730.GA3991@order.stressinduktion.org>
 <CAPoiz9wxxvHfmmMOCvPstzT51BafGfU1u5umxBQ8kqqCE=OzbQ@mail.gmail.com>
 <20131008145331.GA4767@order.stressinduktion.org>
 <20131017044551.GE18135@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jon Mason <jdmason@kudzu.us>, netdev <netdev@vger.kernel.org>,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	herbert@gondor.apana.org.au, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:59220 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab3JRHwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 03:52:53 -0400
Received: by mail-ea0-f181.google.com with SMTP id d10so1737902eaj.12
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 00:52:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131017044551.GE18135@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 17, 2013 at 06:45:52AM CEST, hannes@stressinduktion.org wrote:
>Hi Jon and Jiri!
>
>Just wanted to remind you if you could have a look at this?
>
>If you don't have time to test this may I know your assessment of the
>situation? I could send a compile-time tested patch to disable UFO or if you
>say so we could leave this as is.
>
>Jiri, I would suggest you resend your patches then.


Okay. I will.

>
>Thanks,
>
>  Hannes
>
>[top-posted by intention]
>
>On Tue, Oct 08, 2013 at 04:53:31PM +0200, Hannes Frederic Sowa wrote:
>> On Tue, Oct 08, 2013 at 01:07:29AM -0700, Jon Mason wrote:
>> > On Wed, Oct 2, 2013 at 9:27 AM, Hannes Frederic Sowa
>> > <hannes@stressinduktion.org> wrote:
>> > > Hi!
>> > >
>> > > I have a question regarding UFO and the neterion driver, which as the only one
>> > > advertises hardware UFO support:
>> > >
>> > > The patch discusses in this thread
>> > > http://thread.gmane.org/gmane.linux.network/284348/focus=285405 could change
>> > > some semantics how packets are constructed before submitted to the driver.
>> > >
>> > > We currently guarantee that we have the MAC/IP/UDP header in skb->data and the
>> > > payload is attached in the skb's frags. With the changes discussed in this
>> > > thread it is possible that we also append to skb->data some amount of data
>> > > which is not targeted for the header. From reading the driver sources it seems
>> > > the hardware interprets the skb->data to skb_headlen as the header, so we
>> > > could include some data in the fragments more than once.
>> > 
>> > From my reading of the HW Spec and a quick look at the driver, it
>> > appears that the driver is using one entry in the TX ring for the
>> > header and another for the body of the packet to be fragmented (which
>> > is what the hardware wants).  I don't understand what you are saying,
>> > but if you are asking if simply appending a new header & data to the
>> > end of skb->data will get it out on the wire correct, I don't believe
>> > it will.
>> 
>> No this is not what I tried to say. I'll try to be more clear this
>> time. ;)
>> 
>> We start with an UDP socket which is corked. As soon as we write the
>> first few bytes (smaller than the mtu) onto this socket we put the
>> header in place and the rest of the data is just appended behind the
>> header directly in skb->data via plain ip_append_data.
>> 
>> Now a second write with a length > mtu happens: The ip(6)_append_data
>> will branch to ufo_append. This will fetch the first skb and append
>> to skb->frags.  gso_type and gso_size will be updated on this skb (this
>> currently does not happen but will with the patches discussed in this
>> thread).
>> 
>> If this packet is transmitted down to the device driver we have the udp
>> header in skb->data *and* also the payload from the first write. The
>> payload from the second write is appended as a frag and gso_type and
>> gso_size are set. This header+payload seem to be mapped just after the
>> ufo_in_band_v descriptor as the header in the first tx descriptor:
>> 
>>    4174         txdp->Buffer_Pointer = pci_map_single(sp->pdev, skb->data,
>>    4175                                               frg_len, PCI_DMA_TODEVICE);
>> 
>> frg_len is set to skb_headlen(skb). This happens right after setting up
>> the descriptor for the in-band ufo data.
>> 
>> My guess is that this data isn't split currently by the neterion driver
>> (at least I could not find it in the driver as Eric showed it for bnx2x)
>> so it might reappear in the packets when the hardware fragments the
>> packet and places the first tx ring in front of every packet.
>> 
>> Before these changes we never updated the gso_type and gso_size even when
>> we did append via UFO. So we never had payload in an UFO marked skb->data,
>> only the headers. Now we could also end up with a some payload in the
>> first TX ring, which you said is only for the header.
>> 
>> > I do have hardware that I can try the patch on, if you can walk me
>> > through the use case (unless it is as easy as setup an IPv6 connection
>> > and ping).
>> 
>> Ok, testing this should not be that complicated:
>> 
>> We can test this with plain IPv4/UDP sockets. I would suggest a net-next kernel
>> with this patch from Jiri applied: http://patchwork.ozlabs.org/patch/279691/
>> 
>> --- >8 ---
>> #include <sys/types.h>
>> #include <sys/socket.h>
>> #include <netinet/in.h>
>> #include <arpa/inet.h>
>> #include <linux/udp.h>
>> #include <stdio.h>
>> 
>> int test(int mtu)
>> {
>>         int fd;
>>         const int one = 1;
>>         const int off = 0;
>>         struct sockaddr_in addr = {.sin_family = AF_INET, .sin_port = htons(53) };
>>         unsigned char buffer[3701];
>> 
>>         inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
>> 
>>         fd = socket(AF_INET, SOCK_DGRAM, 0);
>>         connect(fd, (struct sockaddr *) &addr, sizeof(addr));
>> 
>>         setsockopt(fd, IPPROTO_UDP, UDP_CORK, &one, sizeof(one));
>> 
>>         write(fd, "    ", 4);
>>         write(fd, buffer, sizeof(buffer));
>>         write(fd, " ", 1);
>> 
>>         setsockopt(fd, IPPROTO_UDP, UDP_CORK, &off, sizeof(off));
>> 
>>         close(fd);
>> }
>> 
>> int main() {
>>         test(1280);
>> }
>> --- >8 ---
>> 
>> I left out error handling so it is better observed with strace if
>> something went wrong.
>> 
>> You should change the port number and ip address to something reasonable
>> for your network. My guess would be that the spaces (0x20) of the first
>> write is now placed between UDP header and payload of every packet
>> fragmented by the hardware. Would be nice to hear that I am wrong. ;)
>> 
>> Be aware that the above program can cause memory corruption in the kernel
>> if you did not apply Jiri's patch.
>> 
>> Thanks for helping!
>> 
>>   Hannes
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>
>-- 
>gruss,
>
>  Hannes
>
