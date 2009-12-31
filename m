From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC][PATCH v3] Unprivileged: Disable raising of privileges
Date: Thu, 31 Dec 2009 14:00:13 +0100
Message-ID: <m2bphfti1u.fsf@ssh.synack.fr>
References: <m1iqbpwjtp.fsf@fess.ebiederm.org>
	<20091229223631.GB22578@us.ibm.com>
	<m1aax1uoa3.fsf_-_@fess.ebiederm.org>
	<3e8340490912291954v5a837a26p64bd776102d281d7@mail.gmail.com>
	<m1r5qdt721.fsf@fess.ebiederm.org>
	<3e8340490912292057g3e87eaabn115f85b78af2b08c@mail.gmail.com>
	<m1d41w62zc.fsf_-_@fess.ebiederm.org>
	<551280e50912300652r1007dee0j8de750bf33af9b3c@mail.gmail.com>
	<20091230183513.GC14493@us.ibm.com> <m1fx6suswz.fsf@fess.ebiederm.org>
	<20091230201712.GA23999@us.ibm.com>
	<m1hbr8tb8q.fsf_-_@fess.ebiederm.org>
	<20091230212931.233003b9@lxorguk.ukuu.org.uk>
	<m1skasrvnq.fsf@fess.ebiederm.org>
	<20091230230042.5d2e78ac@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com (Eric W. Biederman),
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Andrew G. Morgan" <morgan@kernel.org>,
	Bryan Donlan <bdonlan@gmail.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-15?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Casey Schaufler <casey
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751905AbZLaNAT@vger.kernel.org>
In-Reply-To: <20091230230042.5d2e78ac@lxorguk.ukuu.org.uk> (Alan Cox's message
	of "Wed, 30 Dec 2009 23:00:42 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> Well to be fair its random regurgitated security idea of every year or
> two.

true, last year the same kind of discussion occurs with the 'personal
firewall' aka a network MAC.
http://marc.info/?t=123247387500003&r=3&w=2
http://marc.info/?t=123187029200001&r=2&w=2

> More to the point - we have security_* hooks so this kind of continuous
> security proposal turdstream can stay out of the main part of the kernel.

indeed, LSM framework was design to be the abstraction tool. the 3
design rules were : 

0. truly generic, where using a different security model is merely a
   matter of loading a different kernel module;
1. conceptually simple, minimally invasive, and efficient; and
2. able to support the existing POSIX.1e capabilities logic as an
   optional security module.

so, 'minimally invasive' is keyword. what's why I don't understand the
purpose of this kind of patch, even if I see the goal to achieve:

 int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen)
 {
-	return security_ops->socket_connect(sock, address, addrlen);
+	int ret = 0;
+
+	ret = security_ops->socket_connect(sock, address, addrlen);
+	if (ret)
+		goto out;
+
+#ifdef CONFIG_SECURITY_DISABLENETWORK
+	ret = disablenetwork_security_socket_connect(sock, address, addrlen);
+	if (ret)
+		goto out;
+#endif
+
+out:
+	return ret;
 }

This really seems to be a kind of stacking, but it's not. So are we
going to move LSM framework to support stacking, or are we respecting
the rules of LSM framework (respecting the abstract hooks) ?
This change makes LSM framework no more generic at all.
