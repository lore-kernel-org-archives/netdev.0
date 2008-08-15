From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- retried 2.6.27-rc3 patch (and patch method)
Date: Thu, 14 Aug 2008 20:40:39 -0700 (PDT)
Message-ID: <110640.60391.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-233503818-1218771639=:60391"
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755992AbYHODk4@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--0-233503818-1218771639=:60391
Content-Type: text/plain; charset=us-ascii



> > I used 'git apply --check ' first, and got no errors, so
> > I applied it, built, installed, and rebooted.
> 
> could apply with
> cat revert_*.;patch | patch -p1

Yinghai,

When I got home from work tonight, I decided to make sure that I applied
your patch correctly.  I considered trying it once with cat/patch and
once with 'git apply', and then comparing the results with 'diff'.  I
ended up becoming convinced that 'git apply' worked just fine, and
never tried the cat/patch method:

=================================
$ git show |head
commit 30a2f3c60a84092c8084dfe788b710f8d0768cd4
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue Aug 12 18:55:39 2008 -0700

    Linux 2.6.27-rc3

diff --git a/Makefile b/Makefile
index fd3ca6e..53bf6ec 100644
--- a/Makefile
+++ b/Makefile

$ git apply --check --verbose ../yh-patch1-2.6.27-rc3.diff 
Checking patch arch/x86/kernel/e820.c...
Checking patch arch/x86/kernel/setup.c...
Checking patch include/asm-x86/e820.h...

$ git apply --verbose ../yh-patch1-2.6.27-rc3.diff 
Checking patch arch/x86/kernel/e820.c...
Checking patch arch/x86/kernel/setup.c...
Checking patch include/asm-x86/e820.h...
Applied patch arch/x86/kernel/e820.c cleanly.
Applied patch arch/x86/kernel/setup.c cleanly.
Applied patch include/asm-x86/e820.h cleanly.

dawitbro@fileserver:~/sandbox/git-kernel/linux-2.6$ git status
# Not currently on any branch.
# Changed but not updated:
#   (use "git add <file>..." to update what will be committed)
#
#    modified:   arch/x86/kernel/e820.c
#    modified:   arch/x86/kernel/setup.c
#    modified:   include/asm-x86/e820.h
#
no changes added to commit (use "git add" and/or "git commit -a")

$ git diff > ../yh-patch1-2.6.27-rc3.git-apply.diff 
=================================

As you can see, I renamed your patch file to 'yh-patch1-2.6.27-rc3.diff', and
after applying your patch I created a diff against 2.6.27-rc3 called
'yh-patch1-2.6.27-rc3.git-apply.diff'.

I have attached the output of the following command so that you can see that
your patch applied correctly:

diff -y -W 200  yh-patch1-2.6.27-rc3.diff  yh-patch1-2.6.27-rc3.git-apply.diff

At this point, I retried a kernel with your patch...


> can you try enable kexec and kdump in you .config.
>
> it should works. my .config have config_kexec

I ran 'make oldconfig' to get my .config up to date, then 'make menuconfig'
to make sure I had enabled CONFIG_KEXEC and CONFIG_CRASH_DUMP:

$ egrep 'KEXEC|DUMP' .config
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y


I took these steps, and posted this info, for the sake of our individual and
collective sanity!  ;-)  I want you all to be sure that I applied the patch
correctly, and adjusted the .config as requested, before building the kernel.

The kernel built without error, so I installed and rebooted.  It locked up in
the usual way.  I rebooted, using the "hpet=disable" parameter, and it booted
just fine, just like all the others since 3def3d6d...


>> I do not know how to bisect with your patch if I have a "bad" but no "good"
>> to start with.  Can you explain how I should proceed when I _do_ get home?
>> (I can just enabled those config options and try the patch again, but I am
>> confused about the bisect you are asking me to perform.)
>
> just like the old way doing git-bisect, but before compiling, apply
> the batch, and before git-bisect good or bad, revert the patch.

Since I am still confused about how I should perform the bisect you are
asking for, I will wait until you can clarify.  I responded earlier from
work, where I had no access to a Linux machine, so I could not quote the
git documentation I have read... to explain better why I am confused.  Here
are the sections of 'git help bisect' that I had in mind:

===== BEGIN QUOTED SECTIONS =================
[...]
This command uses git-rev-list --bisect option to help drive the binary
search process to find which change introduced a bug, given an old
"good" commit object name and a later "bad" commit object name.

[...]
Basic bisect commands: start, bad, good

The way you use it is:


$ git bisect start
$ git bisect bad                 # Current version is bad
$ git bisect good v2.6.13-rc2    # v2.6.13-rc2 was the last version
                                 # tested that was good
When you give at least one bad and one good versions, it will bisect
the revision tree and say something like:

Bisecting: 675 revisions left to test after this

[...]
and you continue along, compiling that one, testing it, and depending
on whether it is good or bad, you say "git bisect good" or "git bisect
bad", and ask for the next bisection.
===== END QUOTED SECTIONS =================

If there is a way to use 'git bisect' beginning with a "bad" version
but no "good" version, then it is an advanced usage that I have not
read about and do not understand how to use.  As soon as you tell me
how to carry out the process, I will do so and report the results.


In the meantime, can you comment on the bisection I did last night?
I found something very interesting about the commit that first causes
the lockup (3def3d6d...), and the very next commit (1e934dda...) -- if
I checkout 1e94... and try to revert the changes made in 3def..., the
kernel freezes in spite of the revert.

Because of this, I would conclude that your patch for 2.6.27-rc3 was
doomed before you began, and we should look more carefully at the
commits from February instead of trying to revert at the 2.6.27 HEAD.

I am not a kernel developer, so my opinions are probably safe to ignore,
but I think we should be trying to extract information from my (faulty)
machines about what is happening differently between the "bad" commit
3def3d6d... and the "good" commit before it.


I am too tired to continue my experiments tonight -- it is summer 
semester final exam time at the college where I tutor, and answer 
questions about calculus 2, linear algebra, nursing math, etc., has 
worn me right out -- but while I wait to find out the next step I
should do with the 2.6.27-rc3 patch, I am going to try to get some
useful info printed to the console before the kernel locks up back
in those Feb. revisions.


Thanks,
Dave W.
--0-233503818-1218771639=:60391
Content-Type: text/plain; name="yh-patch1-2.6.27-rc3.compare.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="yh-patch1-2.6.27-rc3.compare.txt"

W1BBVENIXSB4ODY6IHJldmVydCBiYWNrIHRvIHVzZSByZXF1ZXN0X3Jlc291
cmNlIHRvIHJlc2VydmUga2VybmVsIHJlcwkJCQkgICB8CWRpZmYgLS1naXQg
YS9hcmNoL3g4Ni9rZXJuZWwvZTgyMC5jIGIvYXJjaC94ODYva2VybmVsL2U4
MjAuYwoJCQkJCQkJCQkJCQkgICB8CWluZGV4IDlhZjg5MDcuLmZlZmY1Yjcg
MTAwNjQ0ClNpZ25lZC1vZmYtYnk6IFlpbmdoYWkgTHUgPHlobHUua2VybmVs
QGdtYWlsLmNvbT4JCQkJCQkgICB8CS0tLSBhL2FyY2gveDg2L2tlcm5lbC9l
ODIwLmMKCQkJCQkJCQkJCQkJICAgfAkrKysgYi9hcmNoL3g4Ni9rZXJuZWwv
ZTgyMC5jCi0tLQkJCQkJCQkJCQkJCSAgIHwJQEAgLTEyNjcsNyArMTI2Nyw3
IEBAIHN0YXRpYyBpbmxpbmUgY29uc3QgY2hhciAqZTgyMF90eXBlX3RvX3N0
cmluZyhpbnQgZTgyMF90eXBlKQogYXJjaC94ODYva2VybmVsL2U4MjAuYyAg
fCAgIDE3ICsrKysrKysrKysrKysrKy0tCQkJCQkJICAgPAogYXJjaC94ODYv
a2VybmVsL3NldHVwLmMgfCAgIDIyICsrKysrKysrKysrKysrKy0tLS0tLS0J
CQkJCQkgICA8CiBpbmNsdWRlL2FzbS14ODYvZTgyMC5oICB8ICAgIDMgKyst
CQkJCQkJCQkgICA8CiAzIGZpbGVzIGNoYW5nZWQsIDMyIGluc2VydGlvbnMo
KyksIDEwIGRlbGV0aW9ucygtKQkJCQkJCSAgIDwKCQkJCQkJCQkJCQkJICAg
PApJbmRleDogbGludXgtMi42L2FyY2gveDg2L2tlcm5lbC9lODIwLmMJCQkJ
CQkJCSAgIDwKPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQkJCQkgICA8Ci0tLSBs
aW51eC0yLjYub3JpZy9hcmNoL3g4Ni9rZXJuZWwvZTgyMC5jCQkJCQkJCSAg
IDwKKysrIGxpbnV4LTIuNi9hcmNoL3g4Ni9rZXJuZWwvZTgyMC5jCQkJCQkJ
CQkgICA8CkBAIC0xMjY3LDcgKzEyNjcsNyBAQCBzdGF0aWMgaW5saW5lIGNv
bnN0IGNoYXIgKmU4MjBfdHlwZV90b19zCQkJCQkgICA8CiAvKgkJCQkJCQkJ
CQkJCQkgLyoKICAqIE1hcmsgZTgyMCByZXNlcnZlZCBhcmVhcyBhcyBidXN5
IGZvciB0aGUgcmVzb3VyY2UgbWFuYWdlci4JCQkJCQkgICogTWFyayBlODIw
IHJlc2VydmVkIGFyZWFzIGFzIGJ1c3kgZm9yIHRoZSByZXNvdXJjZSBtYW5h
Z2VyLgogICovCQkJCQkJCQkJCQkJCSAgKi8KLXZvaWQgX19pbml0IGU4MjBf
cmVzZXJ2ZV9yZXNvdXJjZXModm9pZCkJCQkJCQkJCS12b2lkIF9faW5pdCBl
ODIwX3Jlc2VydmVfcmVzb3VyY2VzKHZvaWQpCit2b2lkIF9faW5pdCBlODIw
X3Jlc2VydmVfcmVzb3VyY2VzKHN0cnVjdCByZXNvdXJjZSAqKnJlc19rZXJu
ZWwsIGludCBucl9yZXNfaykJCQkJK3ZvaWQgX19pbml0IGU4MjBfcmVzZXJ2
ZV9yZXNvdXJjZXMoc3RydWN0IHJlc291cmNlICoqcmVzX2tlcm5lbCwgaW50
IG5yX3Jlc19rKQogewkJCQkJCQkJCQkJCQkgewogCWludCBpOwkJCQkJCQkJ
CQkJCSAJaW50IGk7CiAJc3RydWN0IHJlc291cmNlICpyZXM7CQkJCQkJCQkJ
CSAJc3RydWN0IHJlc291cmNlICpyZXM7CkBAIC0xMjg3LDcgKzEyODcsMjAg
QEAgdm9pZCBfX2luaXQgZTgyMF9yZXNlcnZlX3Jlc291cmNlcyh2b2lkKQkJ
CQkJCUBAIC0xMjg3LDcgKzEyODcsMjAgQEAgdm9pZCBfX2luaXQgZTgyMF9y
ZXNlcnZlX3Jlc291cmNlcyh2b2lkKQogCQlyZXMtPmVuZCA9IGVuZDsJCQkJ
CQkJCQkJIAkJcmVzLT5lbmQgPSBlbmQ7CiAJCQkJCQkJCQkJCQkJIAogCQly
ZXMtPmZsYWdzID0gSU9SRVNPVVJDRV9NRU0gfCBJT1JFU09VUkNFX0JVU1k7
CQkJCQkJIAkJcmVzLT5mbGFncyA9IElPUkVTT1VSQ0VfTUVNIHwgSU9SRVNP
VVJDRV9CVVNZOwotCQlpbnNlcnRfcmVzb3VyY2UoJmlvbWVtX3Jlc291cmNl
LCByZXMpOwkJCQkJCQktCQlpbnNlcnRfcmVzb3VyY2UoJmlvbWVtX3Jlc291
cmNlLCByZXMpOworCQlyZXF1ZXN0X3Jlc291cmNlKCZpb21lbV9yZXNvdXJj
ZSwgcmVzKTsJCQkJCQkJKwkJcmVxdWVzdF9yZXNvdXJjZSgmaW9tZW1fcmVz
b3VyY2UsIHJlcyk7CisJCWlmIChlODIwLm1hcFtpXS50eXBlID09IEU4MjBf
UkFNKSB7CQkJCQkJCSsJCWlmIChlODIwLm1hcFtpXS50eXBlID09IEU4MjBf
UkFNKSB7CisJCQlpbnQgajsJCQkJCQkJCQkJKwkJCWludCBqOworCQkJLyoJ
CQkJCQkJCQkJKwkJCS8qCisJCQkqIFdlIGRvbid0IGtub3cgd2hpY2ggUkFN
IHJlZ2lvbiBjb250YWlucyBrZXJuZWwgZGF0YSwJCQkJKwkJCSogV2UgZG9u
J3Qga25vdyB3aGljaCBSQU0gcmVnaW9uIGNvbnRhaW5zIGtlcm5lbCBkYXRh
LAorCQkJKiBzbyB3ZSB0cnkgaXQgcmVwZWF0ZWRseSBhbmQgbGV0IHRoZSBy
ZXNvdXJjZSBtYW5hZ2VyCQkJCSsJCQkqIHNvIHdlIHRyeSBpdCByZXBlYXRl
ZGx5IGFuZCBsZXQgdGhlIHJlc291cmNlIG1hbmFnZXIKKwkJCSogdGVzdCBp
dC4JCQkJCQkJCQkrCQkJKiB0ZXN0IGl0LgorCQkJKi8JCQkJCQkJCQkJKwkJ
CSovCisJCQlmb3IgKGogPSAwOyBqIDwgbnJfcmVzX2s7IGorKykgewkJCQkJ
CSsJCQlmb3IgKGogPSAwOyBqIDwgbnJfcmVzX2s7IGorKykgeworCQkJCWlm
ICghcmVzX2tlcm5lbFtqXSkJCQkJCQkJKwkJCQlpZiAoIXJlc19rZXJuZWxb
al0pCisJCQkJCWNvbnRpbnVlOwkJCQkJCQkrCQkJCQljb250aW51ZTsKKwkJ
CQlyZXF1ZXN0X3Jlc291cmNlKHJlcywgcmVzX2tlcm5lbFtqXSk7CQkJCQkr
CQkJCXJlcXVlc3RfcmVzb3VyY2UocmVzLCByZXNfa2VybmVsW2pdKTsKKwkJ
CX0JCQkJCQkJCQkJKwkJCX0KKwkJfQkJCQkJCQkJCQkJKwkJfQogCQlyZXMr
KzsJCQkJCQkJCQkJCSAJCXJlcysrOwogCX0JCQkJCQkJCQkJCQkgCX0KIAkJ
CQkJCQkJCQkJCQkgCkluZGV4OiBsaW51eC0yLjYvYXJjaC94ODYva2VybmVs
L3NldHVwLmMJCQkJCQkJICAgfAlkaWZmIC0tZ2l0IGEvYXJjaC94ODYva2Vy
bmVsL3NldHVwLmMgYi9hcmNoL3g4Ni9rZXJuZWwvc2V0dXAuYwo9PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09CQkJCSAgIHwJaW5kZXggNjhiNDhlMy4uZjgyYzUw
YiAxMDA2NDQKLS0tIGxpbnV4LTIuNi5vcmlnL2FyY2gveDg2L2tlcm5lbC9z
ZXR1cC5jCQkJCQkJCSAgIHwJLS0tIGEvYXJjaC94ODYva2VybmVsL3NldHVw
LmMKKysrIGxpbnV4LTIuNi9hcmNoL3g4Ni9rZXJuZWwvc2V0dXAuYwkJCQkJ
CQkJICAgfAkrKysgYi9hcmNoL3g4Ni9rZXJuZWwvc2V0dXAuYwpAQCAtNDM3
LDYgKzQzNyw3IEBAIHN0YXRpYyB2b2lkIF9faW5pdCByZXNlcnZlX2Vhcmx5
X3NldHVwX2QJCQkJCSAgIHwJQEAgLTQzNyw2ICs0MzcsNyBAQCBzdGF0aWMg
dm9pZCBfX2luaXQgcmVzZXJ2ZV9lYXJseV9zZXR1cF9kYXRhKHZvaWQpCiAg
KiAtLS0tLS0tLS0gQ3Jhc2hrZXJuZWwgcmVzZXJ2YXRpb24gLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tCQkJCQkgICogLS0tLS0tLS0tIENyYXNo
a2VybmVsIHJlc2VydmF0aW9uIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLQogICovCQkJCQkJCQkJCQkJCSAgKi8KIAkJCQkJCQkJCQkJCQkgCitz
dGF0aWMgc3RydWN0IHJlc291cmNlICpjcmFzaGtfcmVzX3B0cjsJCQkJCQkJ
CStzdGF0aWMgc3RydWN0IHJlc291cmNlICpjcmFzaGtfcmVzX3B0cjsKICNp
ZmRlZiBDT05GSUdfS0VYRUMJCQkJCQkJCQkJCSAjaWZkZWYgQ09ORklHX0tF
WEVDCiAJCQkJCQkJCQkJCQkJIAogLyoqCQkJCQkJCQkJCQkJCSAvKioKQEAg
LTUxNyw3ICs1MTgsNyBAQCBzdGF0aWMgdm9pZCBfX2luaXQgcmVzZXJ2ZV9j
cmFzaGtlcm5lbCh2CQkJCQkgICB8CUBAIC01MTcsNyArNTE4LDcgQEAgc3Rh
dGljIHZvaWQgX19pbml0IHJlc2VydmVfY3Jhc2hrZXJuZWwodm9pZCkKIAkJ
CQkJCQkJCQkJCQkgCiAJY3Jhc2hrX3Jlcy5zdGFydCA9IGNyYXNoX2Jhc2U7
CQkJCQkJCQkJIAljcmFzaGtfcmVzLnN0YXJ0ID0gY3Jhc2hfYmFzZTsKIAlj
cmFzaGtfcmVzLmVuZCAgID0gY3Jhc2hfYmFzZSArIGNyYXNoX3NpemUgLSAx
OwkJCQkJCQkgCWNyYXNoa19yZXMuZW5kICAgPSBjcmFzaF9iYXNlICsgY3Jh
c2hfc2l6ZSAtIDE7Ci0JaW5zZXJ0X3Jlc291cmNlKCZpb21lbV9yZXNvdXJj
ZSwgJmNyYXNoa19yZXMpOwkJCQkJCQktCWluc2VydF9yZXNvdXJjZSgmaW9t
ZW1fcmVzb3VyY2UsICZjcmFzaGtfcmVzKTsKKwljcmFzaGtfcmVzX3B0ciA9
ICZjcmFzaGtfcmVzOwkJCQkJCQkJCSsJY3Jhc2hrX3Jlc19wdHIgPSAmY3Jh
c2hrX3JlczsKIH0JCQkJCQkJCQkJCQkJIH0KICNlbHNlCQkJCQkJCQkJCQkJ
CSAjZWxzZQogc3RhdGljIHZvaWQgX19pbml0IHJlc2VydmVfY3Jhc2hrZXJu
ZWwodm9pZCkJCQkJCQkJCSBzdGF0aWMgdm9pZCBfX2luaXQgcmVzZXJ2ZV9j
cmFzaGtlcm5lbCh2b2lkKQpAQCAtNTkzLDYgKzU5NCw5IEBAIHN0cnVjdCB4
ODZfcXVpcmtzICp4ODZfcXVpcmtzIF9faW5pdGRhdGEJCQkJCSAgIHwJQEAg
LTU5Myw2ICs1OTQsOSBAQCBzdHJ1Y3QgeDg2X3F1aXJrcyAqeDg2X3F1aXJr
cyBfX2luaXRkYXRhID0gJmRlZmF1bHRfeDg2X3F1aXJrczsKIAkJCQkJCQkJ
CQkJCQkgCiB2b2lkIF9faW5pdCBzZXR1cF9hcmNoKGNoYXIgKipjbWRsaW5l
X3ApCQkJCQkJCQkgdm9pZCBfX2luaXQgc2V0dXBfYXJjaChjaGFyICoqY21k
bGluZV9wKQogewkJCQkJCQkJCQkJCQkgeworCXN0cnVjdCByZXNvdXJjZSAq
cmVzX2tlcm5lbFs0XTsJCQkJCQkJCQkrCXN0cnVjdCByZXNvdXJjZSAqcmVz
X2tlcm5lbFs0XTsKKwlpbnQgbnVtX3JlczsJCQkJCQkJCQkJCSsJaW50IG51
bV9yZXM7CisJCQkJCQkJCQkJCQkJKwogI2lmZGVmIENPTkZJR19YODZfMzIJ
CQkJCQkJCQkJCSAjaWZkZWYgQ09ORklHX1g4Nl8zMgogCW1lbWNweSgmYm9v
dF9jcHVfZGF0YSwgJm5ld19jcHVfZGF0YSwgc2l6ZW9mKG5ld19jcHVfZGF0
YSkpOwkJCQkJIAltZW1jcHkoJmJvb3RfY3B1X2RhdGEsICZuZXdfY3B1X2Rh
dGEsIHNpemVvZihuZXdfY3B1X2RhdGEpKTsKIAl2aXN3c19lYXJseV9kZXRl
Y3QoKTsJCQkJCQkJCQkJIAl2aXN3c19lYXJseV9kZXRlY3QoKTsKQEAgLTY5
OSwxMSArNzAzLDYgQEAgdm9pZCBfX2luaXQgc2V0dXBfYXJjaChjaGFyICoq
Y21kbGluZV9wKQkJCQkJCUBAIC02OTksMTEgKzcwMyw2IEBAIHZvaWQgX19p
bml0IHNldHVwX2FyY2goY2hhciAqKmNtZGxpbmVfcCkKIAlwcm9iZV9yb21z
KCk7CQkJCQkJCQkJCQkgCXByb2JlX3JvbXMoKTsKICNlbmRpZgkJCQkJCQkJ
CQkJCQkgI2VuZGlmCiAJCQkJCQkJCQkJCQkJIAotCS8qIGFmdGVyIHBhcnNl
X2Vhcmx5X3BhcmFtLCBzbyBjb3VsZCBkZWJ1ZyBpdCAqLwkJCQkJCS0JLyog
YWZ0ZXIgcGFyc2VfZWFybHlfcGFyYW0sIHNvIGNvdWxkIGRlYnVnIGl0ICov
Ci0JaW5zZXJ0X3Jlc291cmNlKCZpb21lbV9yZXNvdXJjZSwgJmNvZGVfcmVz
b3VyY2UpOwkJCQkJCS0JaW5zZXJ0X3Jlc291cmNlKCZpb21lbV9yZXNvdXJj
ZSwgJmNvZGVfcmVzb3VyY2UpOwotCWluc2VydF9yZXNvdXJjZSgmaW9tZW1f
cmVzb3VyY2UsICZkYXRhX3Jlc291cmNlKTsJCQkJCQktCWluc2VydF9yZXNv
dXJjZSgmaW9tZW1fcmVzb3VyY2UsICZkYXRhX3Jlc291cmNlKTsKLQlpbnNl
cnRfcmVzb3VyY2UoJmlvbWVtX3Jlc291cmNlLCAmYnNzX3Jlc291cmNlKTsJ
CQkJCQktCWluc2VydF9yZXNvdXJjZSgmaW9tZW1fcmVzb3VyY2UsICZic3Nf
cmVzb3VyY2UpOwotCQkJCQkJCQkJCQkJCS0KIAlpZiAoZWZpX2VuYWJsZWQp
CQkJCQkJCQkJCSAJaWYgKGVmaV9lbmFibGVkKQogCQllZmlfaW5pdCgpOwkJ
CQkJCQkJCQkgCQllZmlfaW5pdCgpOwogCQkJCQkJCQkJCQkJCSAKQEAgLTg2
NSw3ICs4NjQsMTYgQEAgdm9pZCBfX2luaXQgc2V0dXBfYXJjaChjaGFyICoq
Y21kbGluZV9wKQkJCQkJICAgfAlAQCAtODYzLDcgKzg2MiwxNiBAQCB2b2lk
IF9faW5pdCBzZXR1cF9hcmNoKGNoYXIgKipjbWRsaW5lX3ApCiAJCQkJCQkJ
CQkJCQkJIAogCWt2bV9ndWVzdF9pbml0KCk7CQkJCQkJCQkJCSAJa3ZtX2d1
ZXN0X2luaXQoKTsKIAkJCQkJCQkJCQkJCQkgCi0JZTgyMF9yZXNlcnZlX3Jl
c291cmNlcygpOwkJCQkJCQkJCS0JZTgyMF9yZXNlcnZlX3Jlc291cmNlcygp
OworCXJlc19rZXJuZWxbMF0gPSAmY29kZV9yZXNvdXJjZTsJCQkJCQkJCQkr
CXJlc19rZXJuZWxbMF0gPSAmY29kZV9yZXNvdXJjZTsKKwlyZXNfa2VybmVs
WzFdID0gJmRhdGFfcmVzb3VyY2U7CQkJCQkJCQkJKwlyZXNfa2VybmVsWzFd
ID0gJmRhdGFfcmVzb3VyY2U7CisJcmVzX2tlcm5lbFsyXSA9ICZic3NfcmVz
b3VyY2U7CQkJCQkJCQkJKwlyZXNfa2VybmVsWzJdID0gJmJzc19yZXNvdXJj
ZTsKKwludW1fcmVzID0gMzsJCQkJCQkJCQkJCSsJbnVtX3JlcyA9IDM7CisJ
aWYgKGNyYXNoa19yZXNfcHRyKSB7CQkJCQkJCQkJCSsJaWYgKGNyYXNoa19y
ZXNfcHRyKSB7CisJCXJlc19rZXJuZWxbbnVtX3Jlc10gPSBjcmFzaGtfcmVz
X3B0cjsJCQkJCQkJKwkJcmVzX2tlcm5lbFtudW1fcmVzXSA9IGNyYXNoa19y
ZXNfcHRyOworCQludW1fcmVzKys7CQkJCQkJCQkJCSsJCW51bV9yZXMrKzsK
Kwl9CQkJCQkJCQkJCQkJKwl9CisJZTgyMF9yZXNlcnZlX3Jlc291cmNlcyhy
ZXNfa2VybmVsLCBudW1fcmVzKTsJCQkJCQkJKwllODIwX3Jlc2VydmVfcmVz
b3VyY2VzKHJlc19rZXJuZWwsIG51bV9yZXMpOworCQkJCQkJCQkJCQkJCSsK
IAllODIwX21hcmtfbm9zYXZlX3JlZ2lvbnMobWF4X2xvd19wZm4pOwkJCQkJ
CQkJIAllODIwX21hcmtfbm9zYXZlX3JlZ2lvbnMobWF4X2xvd19wZm4pOwog
CQkJCQkJCQkJCQkJCSAKICNpZmRlZiBDT05GSUdfWDg2XzMyCQkJCQkJCQkJ
CQkgI2lmZGVmIENPTkZJR19YODZfMzIKSW5kZXg6IGxpbnV4LTIuNi9pbmNs
dWRlL2FzbS14ODYvZTgyMC5oCQkJCQkJCQkgICB8CWRpZmYgLS1naXQgYS9p
bmNsdWRlL2FzbS14ODYvZTgyMC5oIGIvaW5jbHVkZS9hc20teDg2L2U4MjAu
aAo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09CQkJCSAgIHwJaW5kZXggMTZhMzFl
Mi4uYTU3NGFkOSAxMDA2NDQKLS0tIGxpbnV4LTIuNi5vcmlnL2luY2x1ZGUv
YXNtLXg4Ni9lODIwLmgJCQkJCQkJICAgfAktLS0gYS9pbmNsdWRlL2FzbS14
ODYvZTgyMC5oCisrKyBsaW51eC0yLjYvaW5jbHVkZS9hc20teDg2L2U4MjAu
aAkJCQkJCQkJICAgfAkrKysgYi9pbmNsdWRlL2FzbS14ODYvZTgyMC5oCkBA
IC0xMjAsNyArMTIwLDggQEAgZXh0ZXJuIHZvaWQgZTgyMF9yZWdpc3Rlcl9h
Y3RpdmVfcmVnaW9ucwkJCQkJICAgfAlAQCAtMTE5LDcgKzExOSw4IEBAIGV4
dGVybiB2b2lkIGU4MjBfcmVnaXN0ZXJfYWN0aXZlX3JlZ2lvbnMoaW50IG5p
ZCwgdW5zaWduZWQgbG9uZyBzdGFydF9wZm4sCiAJCQkJCSB1bnNpZ25lZCBs
b25nIGVuZF9wZm4pOwkJCQkJIAkJCQkJIHVuc2lnbmVkIGxvbmcgZW5kX3Bm
bik7CiBleHRlcm4gdTY0IGU4MjBfaG9sZV9zaXplKHU2NCBzdGFydCwgdTY0
IGVuZCk7CQkJCQkJCQkgZXh0ZXJuIHU2NCBlODIwX2hvbGVfc2l6ZSh1NjQg
c3RhcnQsIHU2NCBlbmQpOwogZXh0ZXJuIHZvaWQgZmluaXNoX2U4MjBfcGFy
c2luZyh2b2lkKTsJCQkJCQkJCQkgZXh0ZXJuIHZvaWQgZmluaXNoX2U4MjBf
cGFyc2luZyh2b2lkKTsKLWV4dGVybiB2b2lkIGU4MjBfcmVzZXJ2ZV9yZXNv
dXJjZXModm9pZCk7CQkJCQkJCQktZXh0ZXJuIHZvaWQgZTgyMF9yZXNlcnZl
X3Jlc291cmNlcyh2b2lkKTsKK3N0cnVjdCByZXNvdXJjZTsJCQkJCQkJCQkJ
CStzdHJ1Y3QgcmVzb3VyY2U7CitleHRlcm4gdm9pZCBlODIwX3Jlc2VydmVf
cmVzb3VyY2VzKHN0cnVjdCByZXNvdXJjZSAqKnJlcywgaW50IG51bSk7CQkJ
CQkrZXh0ZXJuIHZvaWQgZTgyMF9yZXNlcnZlX3Jlc291cmNlcyhzdHJ1Y3Qg
cmVzb3VyY2UgKipyZXMsIGludCBudW0pOwogZXh0ZXJuIHZvaWQgc2V0dXBf
bWVtb3J5X21hcCh2b2lkKTsJCQkJCQkJCQkgZXh0ZXJuIHZvaWQgc2V0dXBf
bWVtb3J5X21hcCh2b2lkKTsKIGV4dGVybiBjaGFyICpkZWZhdWx0X21hY2hp
bmVfc3BlY2lmaWNfbWVtb3J5X3NldHVwKHZvaWQpOwkJCQkJCSBleHRlcm4g
Y2hhciAqZGVmYXVsdF9tYWNoaW5lX3NwZWNpZmljX21lbW9yeV9zZXR1cCh2
b2lkKTsKIGV4dGVybiBjaGFyICptYWNoaW5lX3NwZWNpZmljX21lbW9yeV9z
ZXR1cCh2b2lkKTsJCQkJCQkJIGV4dGVybiBjaGFyICptYWNoaW5lX3NwZWNp
ZmljX21lbW9yeV9zZXR1cCh2b2lkKTsK

--0-233503818-1218771639=:60391--
