From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sysctl: fix min/max handling in
 __do_proc_doulongvec_minmax()
Date: Thu, 07 Oct 2010 18:59:03 +0200
Message-ID: <1286470743.2912.276.camel@edumazet-laptop>
References: <1286025469.2582.1806.camel@edumazet-laptop>
	 <20101004085913.GR14068@sgi.com>
	 <1286183058.18293.26.camel@edumazet-laptop>
	 <20101004093439.GG5189@cr0.nay.redhat.com>
	 <1286187030.18293.33.camel@edumazet-laptop>
	 <20101004103545.GJ5189@cr0.nay.redhat.com>
	 <1286188701.18293.57.camel@edumazet-laptop>
	 <20101005130117.GK5170@cr0.nay.redhat.com>
	 <20101007071859.GD5471@cr0.nay.redhat.com>
	 <20101007092538.GE5471@cr0.nay.redhat.com>
	 <1286445081.2912.15.camel@edumazet-laptop>
	 <m1iq1e3qnn.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Robin Holt <holt@sgi.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1iq1e3qnn.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 07 octobre 2010 =C3=A0 09:37 -0700, Eric W. Biederman a =C3=A9=
crit :

> The difference between long handling and int handling is a
> usability issue.  I don't expect we will be exporting new
> vectors via sysctl, so the conversion of a handful of vectors
> from int to long is where this is most likely to be used.
>=20
> I skimmed through all of what I presume are the current users
> aka linux-2.6.36-rcX and there don't appear to be any users
> of proc_dounlongvec_minmax that use it's vector properties there.
>=20
> Which doubly tells me that incrementing the min and max pointers
> is not what we want to do.
>=20

Thats fine by me, thanks Eric.

Andrew, please remove previous patch from your tree and replace it by
following one :

[PATCH v2] sysctl: fix min/max handling in __do_proc_doulongvec_minmax(=
)

When proc_doulongvec_minmax() is used with an array of longs,
and no min/max check requested (.extra1 or .extra2 being NULL), we
dereference a NULL pointer for the second element of the array.

Noticed while doing some changes in network stack for the "16TB problem=
"

=46ix is to not change min & max pointers in
__do_proc_doulongvec_minmax(), so that all elements of the vector share
an unique min/max limit, like proc_dointvec_minmax().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 kernel/sysctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f88552c..8e45451 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2485,7 +2485,7 @@ static int __do_proc_doulongvec_minmax(void *data=
, struct ctl_table *table, int
 		kbuf[left] =3D 0;
 	}
=20
-	for (; left && vleft--; i++, min++, max++, first=3D0) {
+	for (; left && vleft--; i++, first=3D0) {
 		unsigned long val;
=20
 		if (write) {
