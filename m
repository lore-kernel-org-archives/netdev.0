From: Seif Mazareeb <seif@marvell.com>
Subject: RE: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Fri, 11 Oct 2013 14:04:10 -0700
Message-ID: <0DB595A2CB707F458400BE9663B6A72269C0047841@SC-VEXCH2.marvell.com>
References: <0DB595A2CB707F458400BE9663B6A72269C0047793@SC-VEXCH2.marvell.com>
 <11516872.z0JUlZSHlI@sifl>
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
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:59588 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756647Ab3JKVEU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Oct 2013 17:04:20 -0400
In-Reply-To: <11516872.z0JUlZSHlI@sifl>
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
 include/net/cipso_ipv4.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a7a683e..286b7da 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -290,6 +290,7 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
        unsigned char err_offset = 0;
        u8 opt_len = opt[1];
        u8 opt_iter;
+       u8 tag_len;

        if (opt_len < 8) {
                err_offset = 1;
@@ -302,7 +303,8 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
        }

        for (opt_iter = 6; opt_iter < opt_len;) {
-               if (opt[opt_iter + 1] > (opt_len - opt_iter)) {
+               tag_len = opt[opt_iter + 1];
+               if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))) {
                        err_offset = opt_iter + 1;
                        goto out;
                }
--
1.8.1.2

-----Original Message-----
From: Paul Moore [mailto:paul@paul-moore.com] 
Sent: Friday, October 11, 2013 12:02 PM
To: Seif Mazareeb
Cc: davem@davemloft.net; netdev@vger.kernel.org; thomas.petazzoni@free-electrons.com; Dmitri Epshtein
Subject: Re: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL

On Friday, October 11, 2013 10:58:31 AM Seif Mazareeb wrote:
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
>  include/net/cipso_ipv4.h | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h index 
> a7a683e..047f1f6 100644
> --- a/include/net/cipso_ipv4.h
> +++ b/include/net/cipso_ipv4.h
> @@ -306,6 +306,10 @@ static inline int cipso_v4_validate(const struct 
> sk_buff *skb, err_offset = opt_iter + 1;
>                         goto out;
>                 }
> +
> +               if (opt[opt_iter + 1] == 0)
> +                       break;
> +
>                 opt_iter += opt[opt_iter + 1];
>         }

Thanks for finding and reporting this bug.  Unfortunately, I don't think the supplied patch is the best way to solve this.  Since a length of zero is not valid for any known CIPSO tag types (at least that I am aware of), we should treat a zero length tag as an error, similar to how we treat tags with length values that stretch beyond the option itself.

I'm thinking something like this:

static inline int cipso_v4_validate(const struct sk_buff *skb,
                                    unsigned char **option) {
        unsigned char *opt = *option;
        unsigned char err_offset = 0;
        u8 opt_len = opt[1];
        u8 opt_iter;
        u8 tag_len;

        if (opt_len < 8) {
                err_offset = 1;
                goto out;
        }

        if (get_unaligned_be32(&opt[2]) == 0) {
                err_offset = 2;
                goto out;
        }

        for (opt_iter = 6; opt_iter < opt_len;) {
                tag_len = opt[opt_iter + 1];
                if ((tag_len == 0) || (tag_len > (opt_len - opt_iter))) {
                        err_offset = opt_iter + 1;
                        goto out;
                }
                opt_iter += tag_len;
        }

out:
        *option = opt + err_offset;
        return err_offset;

}

If you want to fixup your patch that would be appreciated, if not, please let me know so I can submit the fix.

Thanks,
-Paul

--
paul moore
www.paul-moore.com
