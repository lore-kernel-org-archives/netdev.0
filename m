From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] S2io: two branches the same in wait_for_cmd_complete()
Date: Mon, 18 Jan 2010 02:20:06 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77061418BF@nekter>
References: <4B53284C.1090405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: "Roel Kluin" <roel.kluin@gmail.com>, <netdev@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"LKML" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754210Ab0ARHfX@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4B53284C.1090405@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Regardless of the bit_state, the branches execute the same code.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
>  drivers/net/s2io.c |   13 +++----------
>  1 files changed, 3 insertions(+), 10 deletions(-)
> 
> Maybe something else was intended?
> this was introduced in commit 9fc93a41a1ad11
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index cc42186..0e353d6 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -3415,16 +3415,9 @@ static int wait_for_cmd_complete(void __iomem
> *addr, u64 busy_bit,
> 
>  	do {
>  		val64 = readq(addr);
> -		if (bit_state == S2IO_BIT_RESET) {
> -			if (!(val64 & busy_bit)) {
> -				ret = SUCCESS;
> -				break;
> -			}
> -		} else {
> -			if (!(val64 & busy_bit)) {
> -				ret = SUCCESS;
> -				break;
> -			}
> +		if (!(val64 & busy_bit)) {
> +			ret = SUCCESS;
> +			break;
>  		}
> 
>  		if (in_interrupt())
> --
Thanks for catching this bug. The fix should be as follows -
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3421,7 +3421,7 @@ static int wait_for_cmd_complete(void __iomem
*addr, u64 busy_bit,
                                break;
                        }
                } else {
-                       if (!(val64 & busy_bit)) {
+                       if (val64 & busy_bit) {
                                ret = SUCCESS;
                                break;
                        }

We've not hit this bug because wait_for_cmd_complete() is always called
with S2IO_BIT_RESET.

Ram
