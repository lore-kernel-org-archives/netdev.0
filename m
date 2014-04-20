From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH] smc91x: fix compile error when SMC_DEBUG >= 2
Date: Sat, 19 Apr 2014 18:24:19 -0700
Message-ID: <20140420012419.GA12770@gup76>
References: <1397879250-32041-1-git-send-email-zlim.lnx@gmail.com>
 <1397880413.3106.2.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Pitre <nico@fluxnic.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Description: Re: [PATCH] smc91x: fix compile error when SMC_DEBUG >= 2
Content-Disposition: inline
In-Reply-To: <1397880413.3106.2.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On Fri, Apr 18, 2014 at 09:06:53PM -0700, Joe Perches wrote:
> On Fri, 2014-04-18 at 20:47 -0700, Zi Shen Lim wrote:
> > When SMC_DEBUG >=3D 2, we hit the following compilation error:
> >=20
> > drivers/net/ethernet/smsc/smc91x.c:85:0:
> > drivers/net/ethernet/smsc/smc91x.c: In function =E2=80=98smc_findir=
q=E2=80=99:
> > drivers/net/ethernet/smsc/smc91x.c:1784:9: error: =E2=80=98dev=E2=80=
=99 undeclared (first use in this function)
> >   DBG(2, dev, "%s: %s\n", CARDNAME, __func__);
> >          ^
> > Fix it by passing in the appropriate netdev pointer.
>=20
> Perhaps verifying the format and args in all cases
> would help avoid more of these in the future.

Sounds good. I can add it as the second patch in the series.

> ---
>  drivers/net/ethernet/smsc/smc91x.c | 25 +++++++++++++++----------
>  1 file changed, 15 insertions(+), 10 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/etherne=
t/smsc/smc91x.c
> index d1b4dca..a8302f5 100644
> --- a/drivers/net/ethernet/smsc/smc91x.c
> +++ b/drivers/net/ethernet/smsc/smc91x.c
> @@ -148,16 +148,19 @@ MODULE_ALIAS("platform:smc91x");
>  #define MII_DELAY		1
> =20
>  #if SMC_DEBUG > 0
> -#define DBG(n, dev, args...)				\
> -	do {						\
> -		if (SMC_DEBUG >=3D (n))			\
> -			netdev_dbg(dev, args);		\
> -	} while (0)
> -
> -#define PRINTK(dev, args...)   netdev_info(dev, args)
> +#define DBG(n, dev, fmt, ...)				\
> +do {								\
> +	if (SMC_DEBUG >=3D (n))					\
> +		netdev_dbg(dev, fmt, ##__VA_ARGS__);		\
> +} while (0)
> +#define PRINTK(dev, fmt, ...)   netdev_info(dev, fmt, ##__VA_ARGS__)
>  #else
> -#define DBG(n, dev, args...)   do { } while (0)
> -#define PRINTK(dev, args...)   netdev_dbg(dev, args)
> +#define DBG(n, dev, fmt, ...)				\
> +do {								\
> +	if (0)					\
> +		netdev_dbg(dev, fmt, ##__VA_ARGS__);		\
> +} while (0)
> +#define PRINTK(dev, fmt, ...)   netdev_dbg(dev, fmt, ##__VA_ARGS__)
>  #endif
> =20
>  #if SMC_DEBUG > 3
> @@ -191,7 +194,9 @@ static void PRINT_PKT(u_char *buf, int length)
>  	pr_cont("\n");
>  }
>  #else
> -#define PRINT_PKT(x...)  do { } while (0)
> +static inline void PRINT_PKT(u_char *buf, int length)
> +{
> +}
>  #endif
> =20

How about the following?
Ok to add your Signed-off-by as well?

Thanks.

---
 drivers/net/ethernet/smsc/smc91x.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/=
smsc/smc91x.c
index d1b4dca..796355a 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -147,18 +147,19 @@ MODULE_ALIAS("platform:smc91x");
  */
 #define MII_DELAY		1
=20
-#if SMC_DEBUG > 0
-#define DBG(n, dev, args...)				\
-	do {						\
-		if (SMC_DEBUG >=3D (n))			\
-			netdev_dbg(dev, args);		\
+#define DBG(n, dev, fmt, ...)					\
+	do {							\
+		if (SMC_DEBUG >=3D (n))				\
+			netdev_dbg(dev, fmt, ##__VA_ARGS__);	\
 	} while (0)
=20
-#define PRINTK(dev, args...)   netdev_info(dev, args)
-#else
-#define DBG(n, dev, args...)   do { } while (0)
-#define PRINTK(dev, args...)   netdev_dbg(dev, args)
-#endif
+#define PRINTK(dev, fmt, ...)					\
+	do {							\
+		if (SMC_DEBUG > 0)				\
+			netdev_info(dev, fmt, ##__VA_ARGS__);	\
+		else						\
+			netdev_dbg(dev, fmt, ##__VA_ARGS__);	\
+	} while (0)
=20
 #if SMC_DEBUG > 3
 static void PRINT_PKT(u_char *buf, int length)
@@ -191,7 +192,7 @@ static void PRINT_PKT(u_char *buf, int length)
 	pr_cont("\n");
 }
 #else
-#define PRINT_PKT(x...)  do { } while (0)
+static inline void PRINT_PKT(u_char *buf, int length) { }
 #endif
=20
