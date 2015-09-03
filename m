From: Joe Perches <joe@perches.com>
Subject: Re: [GIT] Networking
Date: Thu, 03 Sep 2015 11:34:56 -0700
Message-ID: <1441305296.9666.14.camel@perches.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
	 <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
	 <20150903.104032.767889134756094076.davem@davemloft.net>
	 <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-09-03 at 11:22 -0700, Linus Torvalds wrote:
> On Thu, Sep 3, 2015 at 10:40 AM, David Miller <davem@davemloft.net> w=
rote:
> >
> > Linus, what GCC version are you using and what does the warning loo=
k
> > like?
>=20
> I'm on whatever is in F22. gcc -v says
>=20
>    gcc version 5.1.1 20150618 (Red Hat 5.1.1-4) (GCC)
>=20
> and the warning looks like so:
>=20
>   net/mac80211/rate.c: In function =E2=80=98rate_control_cap_mask=E2=80=
=99:
>   net/mac80211/rate.c:719:25: warning: =E2=80=98sizeof=E2=80=99 on ar=
ray function
> parameter =E2=80=98mcs_mask=E2=80=99 will return size of =E2=80=98u8 =
* {aka unsigned char *}=E2=80=99
> [-Wsizeof-array-argument]
>      for (i =3D 0; i < sizeof(mcs_mask); i++)
>                            ^
>=20
> (note the lack of warning about the use of an array in the function
> definition parameter list - I tried to find if there's any way to
> enable such a warning, but couldn't find anything. Maybe my google-fu
> is weak, but more probably that just doesn't exist).

Coccinelle might be a better tool for this but
a possible checkpatch patch is below:

It produces output like:

$ ./scripts/checkpatch.pl -f net/iucv/iucv.c --types=3Dsized_array_argu=
ment
WARNING: Avoid sized array arguments
#716: FILE: net/iucv/iucv.c:716:
+static int iucv_sever_pathid(u16 pathid, u8 userdata[16])
+{

WARNING: Avoid sized array arguments
#878: FILE: net/iucv/iucv.c:878:
+int iucv_path_accept(struct iucv_path *path, struct iucv_handler *hand=
ler,
+		     u8 userdata[16], void *private)
+{

WARNING: Avoid sized array arguments
#925: FILE: net/iucv/iucv.c:925:
+int iucv_path_connect(struct iucv_path *path, struct iucv_handler *han=
dler,
+		      u8 userid[8], u8 system[8], u8 userdata[16],
+		      void *private)
+{

WARNING: Avoid sized array arguments
#988: FILE: net/iucv/iucv.c:988:
+int iucv_path_quiesce(struct iucv_path *path, u8 userdata[16])
+{

WARNING: Avoid sized array arguments
#1020: FILE: net/iucv/iucv.c:1020:
+int iucv_path_resume(struct iucv_path *path, u8 userdata[16])
+{

WARNING: Avoid sized array arguments
#1050: FILE: net/iucv/iucv.c:1050:
+int iucv_path_sever(struct iucv_path *path, u8 userdata[16])
+{

total: 0 errors, 6 warnings, 0 checks, 2119 lines checked
---
 scripts/checkpatch.pl | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index e14dcdb..747b164 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5422,6 +5422,24 @@ sub process {
 			     "externs should be avoided in .c files\n" .  $herecurr);
 		}
=20
+# check for function arguments using arg[SIZE]
+		if ($^V && $^V ge 5.10.0 &&
+		    defined $stat &&
+		    $stat =3D~ /^.\s*(?:$Declare|$DeclareMisordered)\s*$Ident\s*($ba=
lanced_parens)\s*\{/s) {
+			my $func_args =3D $1;
+			if ($func_args =3D~ /(.*)\[\s*(?:$Constant|[A-Z0-9_]+)\s*\]/ && (!d=
efined($1) || $1 !~ /\[\s*\]\s*$/)) {
+				my $ctx =3D '';
+				my $herectx =3D $here . "\n";
+				my $cnt =3D statement_rawlines($stat);
+				for (my $n =3D 0; $n < $cnt; $n++) {
+					$herectx .=3D raw_line($linenr, $n) . "\n";
+					$n =3D $cnt if ($herectx =3D~ /{/);
+				}
+				WARN("SIZED_ARRAY_ARGUMENT",
+				     "Avoid sized array arguments\n" . $herectx);
+			}
+		}
+
 # checks for new __setup's
 		if ($rawline =3D~ /\b__setup\("([^"]*)"/) {
 			my $name =3D $1;
