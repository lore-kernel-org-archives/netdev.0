From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] Re: rib_trie / Fix inflate_threshold_root. Now=15
	size=11 bits
Date: Tue, 14 Jul 2009 21:41:00 +0200
Message-ID: <20090714194100.GA7952@ami.dom.local>
References: <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com> <20090705222301.GA3203@ami.dom.local> <4A513D0D.5070204@itcare.pl> <20090706090207.GB3065@ami.dom.local> <4A53D28D.8060409@itcare.pl> <20090707235029.GA8207@ami.dom.local> <4A565449.4050403@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:49103 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755758AbZGNTld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 15:41:33 -0400
Received: by fxm18 with SMTP id 18so3030963fxm.37
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 12:41:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A565449.4050403@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 09, 2009 at 10:34:17PM +0200, Pawe=B3 Staszewski wrote:
> Jarek Poplawski pisze:
>> On Wed, Jul 08, 2009 at 12:56:13AM +0200, Pawe=B3 Staszewski wrote:
=2E..
>>> Also today i have many messages in dmesg like this:
>>> Fix inflate_threshold_root. Now=3D25 size=3D11 bits
>>> :)
>>>    =20
>>
>>   This is something new and a bit surprising to me: the same thresho=
ld
>> in previous tests didn't generate this? Do you mean more than: "Fix=20
>> inflate_threshold_root. Now=3D15 size=3D11 bits" before?
>>
>>  =20
> Yes. Sorry for that - this info was not all the day but only 5 minute=
s =20
> when i was making tests.
> This info was reported only when all iBGP peers was down/up fast.
>
>>> And after tune :
>>> /sys/module/fib_trie/parameters/inflate_threshold_root
>>> no more info :)
>>>    =20
>>
>> With what value?
>>
>>  =20
> When i set 35 as inflate_threshold_root there was no info even if all=
 =20
> iBGP peers was down/up.

So it looks like the patch tested earlier could be still useful; after
changing the inflate_threshold_root it seems these warnings should be
very rare but there is no reason to alarm users with something they
can't fix optimally, anyway.

Thanks,
Jarek P.
--------------------->
ipv4: Fix inflate_threshold_root automatically

During large updates there could be triggered warnings like: "Fix
inflate_threshold_root. Now=3D25 size=3D11 bits" if inflate() of the ro=
ot
node isn't finished in 10 loops. It should be much rarer now, after
changing the threshold from 15 to 25, and a temporary problem, so
this patch tries to handle it automatically using a fix variable to
increase by one inflate threshold for next root resizes (up to the 35
limit, max fix =3D 10). The fix variable is decreased when root's
inflate() finishes below 7 loops (even if some other, smaller table/
trie is updated -- for simplicity the fix variable is global for now).

Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
Reported-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
Tested-by: Pawel Staszewski <pstaszewski@itcare.pl>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
--- a/net/ipv4/fib_trie.c	2009-07-13 13:32:53.000000000 +0200
+++ b/net/ipv4/fib_trie.c	2009-07-13 15:16:18.000000000 +0200
@@ -327,6 +327,8 @@ static const int inflate_threshold =3D 50;
 static const int halve_threshold_root =3D 15;
 static const int inflate_threshold_root =3D 25;
=20
+static int inflate_threshold_root_fix;
+#define INFLATE_FIX_MAX 10	/* a comment in resize() */
=20
 static void __alias_free_mem(struct rcu_head *head)
 {
@@ -617,7 +619,8 @@ static struct node *resize(struct trie *
 	/* Keep root node larger  */
=20
 	if (!tn->parent)
-		inflate_threshold_use =3D inflate_threshold_root;
+		inflate_threshold_use =3D inflate_threshold_root +
+					inflate_threshold_root_fix;
 	else
 		inflate_threshold_use =3D inflate_threshold;
=20
@@ -641,15 +644,27 @@ static struct node *resize(struct trie *
 	}
=20
 	if (max_resize < 0) {
-		if (!tn->parent)
-			pr_warning("Fix inflate_threshold_root."
-				   " Now=3D%d size=3D%d bits\n",
-				   inflate_threshold_root, tn->bits);
-		else
+		if (!tn->parent) {
+			/*
+			 * It was observed that during large updates even
+			 * inflate_threshold_root =3D 35 might be needed to avoid
+			 * this warning; but it should be temporary, so let's
+			 * try to handle this automatically.
+			 */
+			if (inflate_threshold_root_fix < INFLATE_FIX_MAX)
+				inflate_threshold_root_fix++;
+			else
+				pr_warning("Fix inflate_threshold_root."
+					   " Now=3D%d size=3D%d bits fix=3D%d\n",
+					   inflate_threshold_root, tn->bits,
+					   inflate_threshold_root_fix);
+		} else {
 			pr_warning("Fix inflate_threshold."
 				   " Now=3D%d size=3D%d bits\n",
 				   inflate_threshold, tn->bits);
-	}
+		}
+	} else if (max_resize > 3 && !tn->parent && inflate_threshold_root_fi=
x)
+		inflate_threshold_root_fix--;
=20
 	check_tnode(tn);
=20
