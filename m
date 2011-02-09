From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Linux 2.6.38-rc4 (hysdn: BUG)
Date: Wed, 9 Feb 2011 11:44:00 -0800
Message-ID: <AANLkTimUg8Dm9mZotubcgPHz8_at=_hnbeWUo-LfSALp@mail.gmail.com>
References: <AANLkTimmb26UiBSukdNnVdxLJpCGd=QqpCw8vQoHALh-@mail.gmail.com> <20110209092419.2b335697.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000325576096f762a8049bdeb0b8
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110209092419.2b335697.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--000325576096f762a8049bdeb0b8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 9, 2011 at 9:24 AM, Randy Dunlap <randy.dunlap@oracle.com> wrot=
e:
>
> on x86_64. =A0no HYSDN hardware found (correct).
> Nearly allmodconfig.
>
>
> [ =A0 65.397577] HYSDN: module Rev: 1.6.6.6 loaded
> [ =A0 65.397584] HYSDN: network interface Rev: 1.8.6.4
> [ =A0 65.398057] HYSDN: 0 card(s) found.
> [ =A0 65.398121] BUG: unable to handle kernel paging request at ffffffffa=
06c99f0
> [ =A0 65.398269] IP: [<ffffffffa06c68ba>] hysdn_getrev+0x2e/0x50 [hysdn]
> [ =A0 65.398379] PGD 1a14067 PUD 1a18063 PMD 6f6c1067 PTE 800000006ce8c16=
1
> [ =A0 65.398613] Oops: 0003 [#1] SMP DEBUG_PAGEALLOC
> [ =A0 65.400030]
> [ =A0 65.400030] Pid: 2497, comm: modprobe Not tainted 2.6.38-rc4 #1 0TY5=
65/OptiPlex 745
> [ =A0 65.400030] RIP: 0010:[<ffffffffa06c68ba>] =A0[<ffffffffa06c68ba>] h=
ysdn_getrev+0x2e/0x50 [hysdn]
> [ =A0 65.400030] RSP: 0018:ffff88006eec1e68 =A0EFLAGS: 00010206
> [ =A0 65.400030] RAX: ffffffffa06c99f1 RBX: ffffffffa06c99e9 RCX: ffff880=
07c4159a0

The instruction sequence decodes to

  1e:	be 24 00 00 00       	mov    $0x24,%esi
  23:	48 89 df             	mov    %rbx,%rdi
  26:	e8 5b 39 c0 e0       	callq  0xffffffffe0c03986
  2b:*	c6 40 ff 00          	movb   $0x0,-0x1(%rax)     <-- trapping instru=
ction

which seems to be this

                p =3D strchr(rev, '$');
                *--p =3D 0;

code. And yes, it's total crap, because while "p" and "rev" are "char
*", the string that is passed in is actually of type "const char *",
so that function is seriously broken. It's also seriously broken to
not test that "p" is non-NULL - the function would just break if there
is a colon in the string but not a '$'.

And hysdn_procconf_init() passes in a constant string to the thing:

    static char *hysdn_procconf_revision =3D "$Revision: 1.8.6.4 $";

What happens is that it breaks when we mark the constant section as
read-only, because you have CONFIG_DEBUG_RODATA enabled.

So the fix seems to be to
 - fix the prototype for hysdn_getrev() to not have "const".
 - fix hysdn_procconf_init() to not pass in a constant string to it

The minimal patch would appear to be something like the appended. UNTESTED!

Btw, all of this code seems to go back to before the git history even
started, so it doesn't seem to be new. I assume you haven't tried
booting these all-module kernels before? Or is it just the
DEBUG_RODATA thing that is new for you?

                    Linus

--000325576096f762a8049bdeb0b8
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gjynaju80

IGRyaXZlcnMvaXNkbi9oeXNkbi9oeXNkbl9kZWZzLmggICAgIHwgICAgMiArLQogZHJpdmVycy9p
c2RuL2h5c2RuL2h5c2RuX2luaXQuYyAgICAgfCAgICAyICstCiBkcml2ZXJzL2lzZG4vaHlzZG4v
aHlzZG5fcHJvY2NvbmYuYyB8ICAgIDIgKy0KIDMgZmlsZXMgY2hhbmdlZCwgMyBpbnNlcnRpb25z
KCspLCAzIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvaXNkbi9oeXNkbi9oeXNk
bl9kZWZzLmggYi9kcml2ZXJzL2lzZG4vaHlzZG4vaHlzZG5fZGVmcy5oCmluZGV4IDcyOWRmNDAu
LmQyMWI0YTAgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvaXNkbi9oeXNkbi9oeXNkbl9kZWZzLmgKKysr
IGIvZHJpdmVycy9pc2RuL2h5c2RuL2h5c2RuX2RlZnMuaApAQCAtMjI3LDcgKzIyNyw3IEBAIGV4
dGVybiBoeXNkbl9jYXJkICpjYXJkX3Jvb3Q7CS8qIHBvaW50ZXIgdG8gZmlyc3QgY2FyZCAqLwog
LyoqKioqKioqKioqKioqKioqKioqKioqKiovCiAvKiBpbS9leHBvcnRlZCBmdW5jdGlvbnMgKi8K
IC8qKioqKioqKioqKioqKioqKioqKioqKioqLwotZXh0ZXJuIGNoYXIgKmh5c2RuX2dldHJldihj
b25zdCBjaGFyICopOworZXh0ZXJuIGNoYXIgKmh5c2RuX2dldHJldihjaGFyICopOwogCiAvKiBo
eXNkbl9wcm9jY29uZi5jICovCiBleHRlcm4gaW50IGh5c2RuX3Byb2Njb25mX2luaXQodm9pZCk7
CS8qIGluaXQgcHJvYyBjb25maWcgZmlsZXN5cyAqLwpkaWZmIC0tZ2l0IGEvZHJpdmVycy9pc2Ru
L2h5c2RuL2h5c2RuX2luaXQuYyBiL2RyaXZlcnMvaXNkbi9oeXNkbi9oeXNkbl9pbml0LmMKaW5k
ZXggYjdjYzVjMi4uNGJhMjEyMyAxMDA2NDQKLS0tIGEvZHJpdmVycy9pc2RuL2h5c2RuL2h5c2Ru
X2luaXQuYworKysgYi9kcml2ZXJzL2lzZG4vaHlzZG4vaHlzZG5faW5pdC5jCkBAIC01Myw3ICs1
Myw3IEBAIHN0YXRpYyBoeXNkbl9jYXJkICpjYXJkX2xhc3QgPSBOVUxMOwkvKiBwb2ludGVyIHRv
IGZpcnN0IGNhcmQgKi8KIC8qIGV4dHJhY3QgcmV2aXNpb24gbnVtYmVyIGZyb20gc3RyaW5nIGZv
ciBsb2cgb3V0cHV0ICovCiAvKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqLwogY2hhciAqCi1oeXNkbl9nZXRyZXYoY29uc3QgY2hhciAqcmV2aXNp
b24pCitoeXNkbl9nZXRyZXYoY2hhciAqcmV2aXNpb24pCiB7CiAJY2hhciAqcmV2OwogCWNoYXIg
KnA7CmRpZmYgLS1naXQgYS9kcml2ZXJzL2lzZG4vaHlzZG4vaHlzZG5fcHJvY2NvbmYuYyBiL2Ry
aXZlcnMvaXNkbi9oeXNkbi9oeXNkbl9wcm9jY29uZi5jCmluZGV4IDk2YjNlMzkuLjFjMzk2ZTEg
MTAwNjQ0Ci0tLSBhL2RyaXZlcnMvaXNkbi9oeXNkbi9oeXNkbl9wcm9jY29uZi5jCisrKyBiL2Ry
aXZlcnMvaXNkbi9oeXNkbi9oeXNkbl9wcm9jY29uZi5jCkBAIC0yMyw3ICsyMyw3IEBACiAjaW5j
bHVkZSAiaHlzZG5fZGVmcy5oIgogCiBzdGF0aWMgREVGSU5FX01VVEVYKGh5c2RuX2NvbmZfbXV0
ZXgpOwotc3RhdGljIGNoYXIgKmh5c2RuX3Byb2Njb25mX3JldmlzaW9uID0gIiRSZXZpc2lvbjog
MS44LjYuNCAkIjsKK3N0YXRpYyBjaGFyIGh5c2RuX3Byb2Njb25mX3JldmlzaW9uW10gPSAiJFJl
dmlzaW9uOiAxLjguNi40ICQiOwogCiAjZGVmaW5lIElORk9fT1VUX0xFTiA4MAkJLyogbGVuZ3Ro
IG9mIGluZm8gbGluZSBpbmNsdWRpbmcgbGYgKi8KIAo=
--000325576096f762a8049bdeb0b8--
