From: David Miller <davem@davemloft.net>
Subject: Re: Linux 2.6.38-rc4 (hysdn: BUG)
Date: Wed, 09 Feb 2011 13:57:51 -0800 (PST)
Message-ID: <20110209.135751.112605587.davem@davemloft.net>
References: <20110209092419.2b335697.randy.dunlap@oracle.com>
	<AANLkTimUg8Dm9mZotubcgPHz8_at=_hnbeWUo-LfSALp@mail.gmail.com>
	<20110209132529.76927f5f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn@linux-pingi.de
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753971Ab1BIV5Q convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 16:57:16 -0500
In-Reply-To: <20110209132529.76927f5f.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 9 Feb 2011 13:25:29 -0800

> On Wed, 9 Feb 2011 11:44:00 -0800 Linus Torvalds wrote:
>=20
>> On Wed, Feb 9, 2011 at 9:24 AM, Randy Dunlap <randy.dunlap@oracle.co=
m> wrote:
>> >
>> > on x86_64. =A0no HYSDN hardware found (correct).
>> > Nearly allmodconfig.
>> >
>> >
>> > [ =A0 65.397577] HYSDN: module Rev: 1.6.6.6 loaded
>> > [ =A0 65.397584] HYSDN: network interface Rev: 1.8.6.4
>> > [ =A0 65.398057] HYSDN: 0 card(s) found.
>> > [ =A0 65.398121] BUG: unable to handle kernel paging request at ff=
ffffffa06c99f0
>> > [ =A0 65.398269] IP: [<ffffffffa06c68ba>] hysdn_getrev+0x2e/0x50 [=
hysdn]
>> > [ =A0 65.398379] PGD 1a14067 PUD 1a18063 PMD 6f6c1067 PTE 80000000=
6ce8c161
>> > [ =A0 65.398613] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC
>> > [ =A0 65.400030]
>> > [ =A0 65.400030] Pid: 2497, comm: modprobe Not tainted 2.6.38-rc4 =
#1 0TY565/OptiPlex 745
>> > [ =A0 65.400030] RIP: 0010:[<ffffffffa06c68ba>] =A0[<ffffffffa06c6=
8ba>] hysdn_getrev+0x2e/0x50 [hysdn]
>> > [ =A0 65.400030] RSP: 0018:ffff88006eec1e68 =A0EFLAGS: 00010206
>> > [ =A0 65.400030] RAX: ffffffffa06c99f1 RBX: ffffffffa06c99e9 RCX: =
ffff88007c4159a0
>>=20
>> The instruction sequence decodes to
>>=20
>>   1e:	be 24 00 00 00       	mov    $0x24,%esi
>>   23:	48 89 df             	mov    %rbx,%rdi
>>   26:	e8 5b 39 c0 e0       	callq  0xffffffffe0c03986
>>   2b:*	c6 40 ff 00          	movb   $0x0,-0x1(%rax)     <-- trapping=
 instruction
>>=20
>> which seems to be this
>>=20
>>                 p =3D strchr(rev, '$');
>>                 *--p =3D 0;
>>=20
>> code. And yes, it's total crap, because while "p" and "rev" are "cha=
r
>> *", the string that is passed in is actually of type "const char *",
>> so that function is seriously broken. It's also seriously broken to
>> not test that "p" is non-NULL - the function would just break if the=
re
>> is a colon in the string but not a '$'.
>>=20
>> And hysdn_procconf_init() passes in a constant string to the thing:
>>=20
>>     static char *hysdn_procconf_revision =3D "$Revision: 1.8.6.4 $";
>>=20
>> What happens is that it breaks when we mark the constant section as
>> read-only, because you have CONFIG_DEBUG_RODATA enabled.
>>=20
>> So the fix seems to be to
>>  - fix the prototype for hysdn_getrev() to not have "const".
>>  - fix hysdn_procconf_init() to not pass in a constant string to it
>>=20
>> The minimal patch would appear to be something like the appended. UN=
TESTED!
>=20
> for your patch:
>=20
> Tested-and-acked-by: Randy Dunlap <randy.dunlap@oracle.com>

This stuff just prints out a CVS revision string that hasn't changed
in 10 years into the kernel log.

I propose we just kill this stuff off completely.

I note that there is code in other places of this driver that copy
the read-only revision string into a local string buffer then pass
it into the hysdn_getrev() function, it just doesn't happen in this
one spot.

Anyways, I think I'll fix this like so:

--------------------
isdn: hysdn: Kill (partially buggy) CVS regision log reporting.

Some cases try to modify const strings, and in any event the
CVS revision strings have not changed in over ten years making
these printouts completely worthless.

Just kill all of this stuff off.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hysdn/hysdn_defs.h     |    2 --
 drivers/isdn/hysdn/hysdn_init.c     |   26 +-------------------------
 drivers/isdn/hysdn/hysdn_net.c      |    3 ---
 drivers/isdn/hysdn/hysdn_procconf.c |    3 +--
 4 files changed, 2 insertions(+), 32 deletions(-)

diff --git a/drivers/isdn/hysdn/hysdn_defs.h b/drivers/isdn/hysdn/hysdn=
_defs.h
index 729df40..18b801a 100644
--- a/drivers/isdn/hysdn/hysdn_defs.h
+++ b/drivers/isdn/hysdn/hysdn_defs.h
@@ -227,7 +227,6 @@ extern hysdn_card *card_root;	/* pointer to first c=
ard */
 /*************************/
 /* im/exported functions */
 /*************************/
-extern char *hysdn_getrev(const char *);
=20
 /* hysdn_procconf.c */
 extern int hysdn_procconf_init(void);	/* init proc config filesys */
@@ -259,7 +258,6 @@ extern int hysdn_tx_cfgline(hysdn_card *, unsigned =
char *,
=20
 /* hysdn_net.c */
 extern unsigned int hynet_enable;=20
-extern char *hysdn_net_revision;
 extern int hysdn_net_create(hysdn_card *);	/* create a new net device =
*/
 extern int hysdn_net_release(hysdn_card *);	/* delete the device */
 extern char *hysdn_net_getname(hysdn_card *);	/* get name of net inter=
face */
diff --git a/drivers/isdn/hysdn/hysdn_init.c b/drivers/isdn/hysdn/hysdn=
_init.c
index b7cc5c2..0ab42ac 100644
--- a/drivers/isdn/hysdn/hysdn_init.c
+++ b/drivers/isdn/hysdn/hysdn_init.c
@@ -36,7 +36,6 @@ MODULE_DESCRIPTION("ISDN4Linux: Driver for HYSDN card=
s");
 MODULE_AUTHOR("Werner Cornelius");
 MODULE_LICENSE("GPL");
=20
-static char *hysdn_init_revision =3D "$Revision: 1.6.6.6 $";
 static int cardmax;		/* number of found cards */
 hysdn_card *card_root =3D NULL;	/* pointer to first card */
 static hysdn_card *card_last =3D NULL;	/* pointer to first card */
@@ -49,25 +48,6 @@ static hysdn_card *card_last =3D NULL;	/* pointer to=
 first card */
 /* Additionally newer versions may be activated without rebooting.    =
      */
 /*********************************************************************=
*******/
=20
-/******************************************************/
-/* extract revision number from string for log output */
-/******************************************************/
-char *
-hysdn_getrev(const char *revision)
-{
-	char *rev;
-	char *p;
-
-	if ((p =3D strchr(revision, ':'))) {
-		rev =3D p + 2;
-		p =3D strchr(rev, '$');
-		*--p =3D 0;
-	} else
-		rev =3D "???";
-	return rev;
-}
-
-
 /*********************************************************************=
*******/
 /* init_module is called once when the module is loaded to do all nece=
ssary */
 /* things like autodetect...                                          =
      */
@@ -175,13 +155,9 @@ static int hysdn_have_procfs;
 static int __init
 hysdn_init(void)
 {
-	char tmp[50];
 	int rc;
=20
-	strcpy(tmp, hysdn_init_revision);
-	printk(KERN_NOTICE "HYSDN: module Rev: %s loaded\n", hysdn_getrev(tmp=
));
-	strcpy(tmp, hysdn_net_revision);
-	printk(KERN_NOTICE "HYSDN: network interface Rev: %s \n", hysdn_getre=
v(tmp));
+	printk(KERN_NOTICE "HYSDN: module loaded\n");
=20
 	rc =3D pci_register_driver(&hysdn_pci_driver);
 	if (rc)
diff --git a/drivers/isdn/hysdn/hysdn_net.c b/drivers/isdn/hysdn/hysdn_=
net.c
index feec8d8..11f2cce 100644
--- a/drivers/isdn/hysdn/hysdn_net.c
+++ b/drivers/isdn/hysdn/hysdn_net.c
@@ -26,9 +26,6 @@
 unsigned int hynet_enable =3D 0xffffffff;=20
 module_param(hynet_enable, uint, 0);
=20
-/* store the actual version for log reporting */
-char *hysdn_net_revision =3D "$Revision: 1.8.6.4 $";
-
 #define MAX_SKB_BUFFERS 20	/* number of buffers for keeping TX-data */
=20
 /*********************************************************************=
*******/
diff --git a/drivers/isdn/hysdn/hysdn_procconf.c b/drivers/isdn/hysdn/h=
ysdn_procconf.c
index 96b3e39..5fe83bd 100644
--- a/drivers/isdn/hysdn/hysdn_procconf.c
+++ b/drivers/isdn/hysdn/hysdn_procconf.c
@@ -23,7 +23,6 @@
 #include "hysdn_defs.h"
=20
 static DEFINE_MUTEX(hysdn_conf_mutex);
-static char *hysdn_procconf_revision =3D "$Revision: 1.8.6.4 $";
=20
 #define INFO_OUT_LEN 80		/* length of info line including lf */
=20
@@ -404,7 +403,7 @@ hysdn_procconf_init(void)
 		card =3D card->next;	/* next entry */
 	}
=20
-	printk(KERN_NOTICE "HYSDN: procfs Rev. %s initialised\n", hysdn_getre=
v(hysdn_procconf_revision));
+	printk(KERN_NOTICE "HYSDN: procfs initialised\n");
 	return (0);
 }				/* hysdn_procconf_init */
=20
--=20
1.7.4

