From: Miklos Szeredi <mszeredi@redhat.com>
Subject: Re: kernel BUG at net/unix/garbage.c:149!"
Date: Tue, 30 Aug 2016 11:18:10 +0200
Message-ID: <CAOssrKcfncAYsQWkfLGFgoOxAQJVT2hYVWdBA6Cw7hhO8RJ_wQ@mail.gmail.com>
References: <57BDAE06.1040400@kyup.com> <9dde3145-9128-ffef-1b84-e3bd429dd4e8@stressinduktion.org>
 <CAOssrKddiaWQX+v7FZTJg9mwyhxHJCDQQMUJVwP17-z1ATrKWA@mail.gmail.com> <CAOssrKedUEAcZThhd2FB9UPzhr+5ErLjB=3+1z1XdnFeP6wvmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11406446b05c88053b46755f
Cc: Nikolay Borisov <kernel@kyup.com>,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOssrKedUEAcZThhd2FB9UPzhr+5ErLjB=3+1z1XdnFeP6wvmg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a11406446b05c88053b46755f
Content-Type: text/plain; charset=UTF-8

On Tue, Aug 30, 2016 at 12:37 AM, Miklos Szeredi <mszeredi@redhat.com> wrote:
> On Sat, Aug 27, 2016 at 11:55 AM, Miklos Szeredi <mszeredi@redhat.com> wrote:

> crash> list -H gc_inflight_list unix_sock.link -s unix_sock.inflight |
> grep counter | cut -d= -f2 | awk '{s+=$1} END {print s}'
> 130
> crash> p unix_tot_inflight
> unix_tot_inflight = $2 = 135
>
> We've lost track of a total of five inflight sockets, so it's not a
> one-off thing.  Really weird...  Now off to sleep, maybe I'll dream of
> the solution.

Okay, found one bug: gc assumes that in-flight sockets that don't have
an external ref can't gain one while unix_gc_lock is held.  That is
true because unix_notinflight() will be called before detaching fds,
which takes unix_gc_lock.  Only MSG_PEEK was somehow overlooked.  That
one also clones the fds, also keeping them in the skb.  But through
MSG_PEEK an external reference can definitely be gained without ever
touching unix_gc_lock.

Not sure whether the reported bug can be explained by this.  Can you
confirm the MSG_PEEK was used in the setup?

Does someone want to write a stress test for SCM_RIGHTS + MSG_PEEK?

Anyway, attaching a fix that works by acquiring unix_gc_lock in case
of MSG_PEEK also.  It is trivially correct, but I haven't tested it.

Thanks,
Miklos

--001a11406446b05c88053b46755f
Content-Type: text/x-patch; charset=US-ASCII;
	name="af_unix-fix-garbage-collect-vs-msg_peek.patch"
Content-Disposition: attachment;
	filename="af_unix-fix-garbage-collect-vs-msg_peek.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ish9dnze0

RnJvbTogTWlrbG9zIFN6ZXJlZGkgPG1zemVyZWRpQHJlZGhhdC5jb20+ClN1YmplY3Q6IGFmX3Vu
aXg6IGZpeCBnYXJiYWdlIGNvbGxlY3QgdnMuIE1TR19QRUVLCgpHYyBhc3N1bWVzIHRoYXQgaW4t
ZmxpZ2h0IHNvY2tldHMgdGhhdCBkb24ndCBoYXZlIGFuIGV4dGVybmFsIHJlZiBjYW4ndApnYWlu
IG9uZSB3aGlsZSB1bml4X2djX2xvY2sgaXMgaGVsZC4gIFRoYXQgaXMgdHJ1ZSBiZWNhdXNlCnVu
aXhfbm90aW5mbGlnaHQoKSB3aWxsIGJlIGNhbGxlZCBiZWZvcmUgZGV0YWNoaW5nIGZkcywgd2hp
Y2ggdGFrZXMKdW5peF9nY19sb2NrLgoKT25seSBNU0dfUEVFSyB3YXMgc29tZWhvdyBvdmVybG9v
a2VkLiAgVGhhdCBvbmUgYWxzbyBjbG9uZXMgdGhlIGZkcywgYWxzbwprZWVwaW5nIHRoZW0gaW4g
dGhlIHNrYi4gIEJ1dCB0aHJvdWdoIE1TR19QRUVLIGFuIGV4dGVybmFsIHJlZmVyZW5jZSBjYW4K
ZGVmaW5pdGVseSBiZSBnYWluZWQgd2l0aG91dCBldmVyIHRvdWNoaW5nIHVuaXhfZ2NfbG9jay4K
ClNpZ25lZC1vZmYtYnk6IE1pa2xvcyBTemVyZWRpIDxtc3plcmVkaUByZWRoYXQuY29tPgpDYzog
PHN0YWJsZUB2Z2VyLmtlcm5lbC5vcmc+Ci0tLQogaW5jbHVkZS9uZXQvYWZfdW5peC5oIHwgICAg
MSArCiBuZXQvdW5peC9hZl91bml4LmMgICAgfCAgIDE1ICsrKysrKysrKysrKystLQogbmV0L3Vu
aXgvZ2FyYmFnZS5jICAgIHwgICAgNiArKysrKysKIDMgZmlsZXMgY2hhbmdlZCwgMjAgaW5zZXJ0
aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKCi0tLSBhL2luY2x1ZGUvbmV0L2FmX3VuaXguaAorKysg
Yi9pbmNsdWRlL25ldC9hZl91bml4LmgKQEAgLTEwLDYgKzEwLDcgQEAgdm9pZCB1bml4X2luZmxp
Z2h0KHN0cnVjdCB1c2VyX3N0cnVjdCAqdQogdm9pZCB1bml4X25vdGluZmxpZ2h0KHN0cnVjdCB1
c2VyX3N0cnVjdCAqdXNlciwgc3RydWN0IGZpbGUgKmZwKTsKIHZvaWQgdW5peF9nYyh2b2lkKTsK
IHZvaWQgd2FpdF9mb3JfdW5peF9nYyh2b2lkKTsKK3ZvaWQgdW5peF9nY19iYXJyaWVyKHZvaWQp
Owogc3RydWN0IHNvY2sgKnVuaXhfZ2V0X3NvY2tldChzdHJ1Y3QgZmlsZSAqZmlscCk7CiBzdHJ1
Y3Qgc29jayAqdW5peF9wZWVyX2dldChzdHJ1Y3Qgc29jayAqKTsKIAotLS0gYS9uZXQvdW5peC9h
Zl91bml4LmMKKysrIGIvbmV0L3VuaXgvYWZfdW5peC5jCkBAIC0xNTYzLDYgKzE1NjMsMTcgQEAg
c3RhdGljIGludCB1bml4X2F0dGFjaF9mZHMoc3RydWN0IHNjbV9jbwogCXJldHVybiBtYXhfbGV2
ZWw7CiB9CiAKK3N0YXRpYyB2b2lkIHVuaXhfcGVla19mZHMoc3RydWN0IHNjbV9jb29raWUgKnNj
bSwgc3RydWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlzY20tPmZwID0gc2NtX2ZwX2R1cChVTklYQ0Io
c2tiKS5mcCk7CisJLyoKKwkgKiBEdXJpbmcgZ2FyYmFnZSBjb2xsZWN0aW9uIGl0IGlzIGFzc3Vt
ZWQgdGhhdCBpbi1mbGlnaHQgc29ja2V0cyBkb24ndAorCSAqIGdldCBhIG5ldyBleHRlcm5hbCBy
ZWZlcmVuY2UuICBTbyB3ZSBuZWVkIHRvIHdhaXQgdW50aWwgY3VycmVudCBydW4KKwkgKiBmaW5p
c2hlcy4KKwkgKi8KKwl1bml4X2djX2JhcnJpZXIoKTsKK30KKwogc3RhdGljIGludCB1bml4X3Nj
bV90b19za2Ioc3RydWN0IHNjbV9jb29raWUgKnNjbSwgc3RydWN0IHNrX2J1ZmYgKnNrYiwgYm9v
bCBzZW5kX2ZkcykKIHsKIAlpbnQgZXJyID0gMDsKQEAgLTIxOTUsNyArMjIwNiw3IEBAIHN0YXRp
YyBpbnQgdW5peF9kZ3JhbV9yZWN2bXNnKHN0cnVjdCBzb2MKIAkJc2tfcGVla19vZmZzZXRfZndk
KHNrLCBzaXplKTsKIAogCQlpZiAoVU5JWENCKHNrYikuZnApCi0JCQlzY20uZnAgPSBzY21fZnBf
ZHVwKFVOSVhDQihza2IpLmZwKTsKKwkJCXVuaXhfcGVla19mZHMoJnNjbSwgc2tiKTsKIAl9CiAJ
ZXJyID0gKGZsYWdzICYgTVNHX1RSVU5DKSA/IHNrYi0+bGVuIC0gc2tpcCA6IHNpemU7CiAKQEAg
LTI0MzUsNyArMjQ0Niw3IEBAIHN0YXRpYyBpbnQgdW5peF9zdHJlYW1fcmVhZF9nZW5lcmljKHN0
cnUKIAkJCS8qIEl0IGlzIHF1ZXN0aW9uYWJsZSwgc2VlIG5vdGUgaW4gdW5peF9kZ3JhbV9yZWN2
bXNnLgogCQkJICovCiAJCQlpZiAoVU5JWENCKHNrYikuZnApCi0JCQkJc2NtLmZwID0gc2NtX2Zw
X2R1cChVTklYQ0Ioc2tiKS5mcCk7CisJCQkJdW5peF9wZWVrX2Zkcygmc2NtLCBza2IpOwogCiAJ
CQlza19wZWVrX29mZnNldF9md2Qoc2ssIGNodW5rKTsKIAotLS0gYS9uZXQvdW5peC9nYXJiYWdl
LmMKKysrIGIvbmV0L3VuaXgvZ2FyYmFnZS5jCkBAIC0yNjYsNiArMjY2LDEyIEBAIHZvaWQgd2Fp
dF9mb3JfdW5peF9nYyh2b2lkKQogCXdhaXRfZXZlbnQodW5peF9nY193YWl0LCBnY19pbl9wcm9n
cmVzcyA9PSBmYWxzZSk7CiB9CiAKK3ZvaWQgdW5peF9nY19iYXJyaWVyKHZvaWQpCit7CisJc3Bp
bl9sb2NrKCZ1bml4X2djX2xvY2spOworCXNwaW5fdW5sb2NrKCZ1bml4X2djX2xvY2spOworfQor
CiAvKiBUaGUgZXh0ZXJuYWwgZW50cnkgcG9pbnQ6IHVuaXhfZ2MoKSAqLwogdm9pZCB1bml4X2dj
KHZvaWQpCiB7Cg==
--001a11406446b05c88053b46755f--
