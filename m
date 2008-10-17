From: Ingo Molnar <mingo@elte.hu>
Subject: Re: powerpc allmodconfig
Date: Fri, 17 Oct 2008 13:09:45 +0200
Message-ID: <20081017110945.GA32364@elte.hu>
References: <20081015213337.a99a9595.akpm@linux-foundation.org> <20081015.220247.262683261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, tiwai@suse.de,
	linux-ext4@vger.kernel.org, netdev@vger.kernel.org,
	linux-ide@vger.kernel.org, bzolnier@gmail.com,
	marek.vasut@gmail.com, dwmw2@infradead.org, mark.fasheh@oracle.com,
	ralf@linux-mips.org, mchehab@infradead.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ext4-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081015.220247.262683261.davem@davemloft.net>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> > net/dccp/options.c: In function 'dccp_parse_options':=20
> > net/dccp/options.c:67: warning: 'value' may be used uninitialized i=
n=20
> > this function
>=20
> Known issue, not trivial to fix, gcc is just being incredibly silly=20
> here as it can't see all of the control flow.

i just ran into this - do you have any objection against the patch=20
below?

Should we have a cleaner annotation perhaps instead of=20
uninitialized_var()? Something like:

 #define __used          __attribute__((used))

?

	Ingo

---------->
=46rom d917af0bd043eab40d57f79cba9cf7a7b265a205 Mon Sep 17 00:00:00 200=
1
=46rom: Ingo Molnar <mingo@elte.hu>
Date: Fri, 17 Oct 2008 12:41:30 +0200
Subject: [PATCH] fix warning in net/dccp/options.c
MIME-Version: 1.0
Content-Type: text/plain; charset=3Dutf-8
Content-Transfer-Encoding: 8bit

fix this warning:

  net/dccp/options.c: In function =E2=80=98dccp_parse_options=E2=80=99:
  net/dccp/options.c:67: warning: =E2=80=98value=E2=80=99 may be used u=
ninitialized in this function

This is a bogus GCC warning. The compiler does not recognize the relati=
on
between "value" and "mandatory" variables: the code flow can ever reach
the "out_invalid_option:" label if 'mandatory' is set to 1, and when
'mandatory' is non-zero, we'll always have 'value' initialized.

Help out the compiler by annotating the variable.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 net/dccp/options.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/options.c b/net/dccp/options.c
index 0809b63..18dcfb9 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -64,7 +64,7 @@ int dccp_parse_options(struct sock *sk, struct dccp_r=
equest_sock *dreq,
 					(dh->dccph_doff * 4);
 	struct dccp_options_received *opt_recv =3D &dp->dccps_options_receive=
d;
 	unsigned char opt, len;
-	unsigned char *value;
+	unsigned char *uninitialized_var(value);
 	u32 elapsed_time;
 	__be32 opt_val;
 	int rc;
--
To unsubscribe from this list: send the line "unsubscribe linux-ext4" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
