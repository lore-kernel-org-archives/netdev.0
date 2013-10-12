From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Sat, 12 Oct 2013 07:57:27 -0400
Message-ID: <2291823.ee0I8c00DA@olly>
References: <0DB595A2CB707F458400BE9663B6A72269C0047793@SC-VEXCH2.marvell.com> <11516872.z0JUlZSHlI@sifl> <0DB595A2CB707F458400BE9663B6A72269C0047841@SC-VEXCH2.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	Dmitri Epshtein <dima@marvell.com>
To: Seif Mazareeb <seif@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f52.google.com ([209.85.128.52]:50418 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab3JLL5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 07:57:30 -0400
Received: by mail-qe0-f52.google.com with SMTP id w7so4092951qeb.11
        for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 04:57:29 -0700 (PDT)
In-Reply-To: <0DB595A2CB707F458400BE9663B6A72269C0047841@SC-VEXCH2.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, October 11, 2013 2:04:10 PM Seif Mazareeb wrote:
> When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function could
> loop forever in the main loop if opt[opt_iter +1] == 0, this will causing a
> kernel crash in an SMP system, since the CPU executing this function will
> stall /not respond to IPIs.
> 
> This problem can be reproduced by running the IP Stack Integrity Checker
> (http://isic.sourceforge.net) using the following command on a Linux machine
> connected to DUT:
> 
> "icmpsic -s rand -d <DUT IP address> -r 123456"
> wait (1-2 min)
> 
> Signed-off-by: Seif Mazareeb <seif@marvell.com>
> ---
>  include/net/cipso_ipv4.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
> index a7a683e..286b7da 100644
> --- a/include/net/cipso_ipv4.h
> +++ b/include/net/cipso_ipv4.h
> @@ -290,6 +290,7 @@ static inline int cipso_v4_validate(const struct sk_buff
> *skb, unsigned char err_offset = 0;
>         u8 opt_len = opt[1];
>         u8 opt_iter;
> +       u8 tag_len;
> 
>         if (opt_len < 8) {
>                 err_offset = 1;
> @@ -302,7 +303,8 @@ static inline int cipso_v4_validate(const struct sk_buff
> *skb, }
> 
>         for (opt_iter = 6; opt_iter < opt_len;) {
> -               if (opt[opt_iter + 1] > (opt_len - opt_iter)) {
> +               tag_len = opt[opt_iter + 1];
> +               if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len -
> opt_iter))) { err_offset = opt_iter + 1;
>                         goto out;
>                 }

You should also use 'tag_len' inside the for-loop, and after the if-block, 
where we increment 'opt_iter'.  See my original reply for an example.

-- 
paul moore
www.paul-moore.com
