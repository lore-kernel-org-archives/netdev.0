From: Seif Mazareeb <seif@marvell.com>
Subject: RE: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Sat, 12 Oct 2013 22:21:50 -0700
Message-ID: <0DB595A2CB707F458400BE9663B6A72269C00479DF@SC-VEXCH2.marvell.com>
References: <0DB595A2CB707F458400BE9663B6A72269C0047793@SC-VEXCH2.marvell.com>
 <11516872.z0JUlZSHlI@sifl>
 <0DB595A2CB707F458400BE9663B6A72269C0047841@SC-VEXCH2.marvell.com>
 <2291823.ee0I8c00DA@olly>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	Dmitri Epshtein <dima@marvell.com>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:31507 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751278Ab3JMFV4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Oct 2013 01:21:56 -0400
In-Reply-To: <2291823.ee0I8c00DA@olly>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function could loop
forever in the main loop if opt[opt_iter +1] == 0, this will causing a kernel
crash in an SMP system, since the CPU executing this function will
stall /not respond to IPIs.

This problem can be reproduced by running the IP Stack Integrity Checker
(http://isic.sourceforge.net) using the following command on a Linux machine
connected to DUT:

"icmpsic -s rand -d <DUT IP address> -r 123456"
wait (1-2 min)

Signed-off-by: Seif Mazareeb <seif@marvell.com>
---
 include/net/cipso_ipv4.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a7a683e..a8c2ef6 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -290,6 +290,7 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
        unsigned char err_offset = 0;
        u8 opt_len = opt[1];
        u8 opt_iter;
+       u8 tag_len;

        if (opt_len < 8) {
                err_offset = 1;
@@ -302,11 +303,12 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
        }

        for (opt_iter = 6; opt_iter < opt_len;) {
-               if (opt[opt_iter + 1] > (opt_len - opt_iter)) {
+               tag_len = opt[opt_iter + 1];
+               if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))) {
                        err_offset = opt_iter + 1;
                        goto out;
                }
-               opt_iter += opt[opt_iter + 1];
+               opt_iter += tag_len;
        }

 out:
--
1.8.1.2

-----Original Message-----
From: Paul Moore [mailto:paul@paul-moore.com] 
Sent: Saturday, October 12, 2013 4:57 AM
To: Seif Mazareeb
Cc: davem@davemloft.net; netdev@vger.kernel.org; thomas.petazzoni@free-electrons.com; Dmitri Epshtein
Subject: Re: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL

On Friday, October 11, 2013 2:04:10 PM Seif Mazareeb wrote:
> When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function 
> could loop forever in the main loop if opt[opt_iter +1] == 0, this 
> will causing a kernel crash in an SMP system, since the CPU executing 
> this function will stall /not respond to IPIs.
> 
> This problem can be reproduced by running the IP Stack Integrity 
> Checker
> (http://isic.sourceforge.net) using the following command on a Linux 
> machine connected to DUT:
> 
> "icmpsic -s rand -d <DUT IP address> -r 123456"
> wait (1-2 min)
> 
> Signed-off-by: Seif Mazareeb <seif@marvell.com>
> ---
>  include/net/cipso_ipv4.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h index 
> a7a683e..286b7da 100644
> --- a/include/net/cipso_ipv4.h
> +++ b/include/net/cipso_ipv4.h
> @@ -290,6 +290,7 @@ static inline int cipso_v4_validate(const struct 
> sk_buff *skb, unsigned char err_offset = 0;
>         u8 opt_len = opt[1];
>         u8 opt_iter;
> +       u8 tag_len;
> 
>         if (opt_len < 8) {
>                 err_offset = 1;
> @@ -302,7 +303,8 @@ static inline int cipso_v4_validate(const struct 
> sk_buff *skb, }
> 
>         for (opt_iter = 6; opt_iter < opt_len;) {
> -               if (opt[opt_iter + 1] > (opt_len - opt_iter)) {
> +               tag_len = opt[opt_iter + 1];
> +               if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len -
> opt_iter))) { err_offset = opt_iter + 1;
>                         goto out;
>                 }

You should also use 'tag_len' inside the for-loop, and after the if-block, where we increment 'opt_iter'.  See my original reply for an example.

--
paul moore
www.paul-moore.com
