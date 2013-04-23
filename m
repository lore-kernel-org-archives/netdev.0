From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Mon, 22 Apr 2013 17:23:04 -0700
Message-ID: <CA+55aFy0jPr5udwJx8cZ-QFs-OgZzQ_NJm_VSj_cS7tsKUn3Kw@mail.gmail.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11c18aa4608aca04dafc30f0
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a11c18aa4608aca04dafc30f0
Content-Type: text/plain; charset=UTF-8

[ Ugh, resending because I had mistakenly set the html bit and all the
mailing lists just refused the original... ]

So I was playing with sparse again, because the MIPS people had hit a
bug with the fact that they had made PAGE_MASK an *unsigned* type, and
then doing the ~ (binary not) operation on it does the wrong thing
when you operate on bigger types, like hardware 36-bit physical
addresses.

See commit 3b5e50edaf50 (and commit c17a6554 that it reverts).

So the issue is that let's say that you have a constant (or variable,
for that matter) that is of type "unsigned int", and then you use that
to mask a variable of a larger size (say it's an "unsigned long" on a
64-bit arch, or it's a phys_addr_t on a 32-bit arch with PAE). So the
code looks basically like a variation of something like this:

     u64 value = ...;

     value &= ~bitmask;

What happens?

What happens is that the "~bitmask" is done in the *narrower* type,
and then - because the narrower type is unsigned - the cast to the
wider type is done as an *unsigned* cast, so what you *think* happens
is that it clears the bits that are set in "bitmask", but what
*actually* happens is that yes, you clear the bits that are set in
:bitmask", but you *also* clear the upper bits of value.

Now, why am I posting about this MIPS-specific small detail on to x86 people?

Because I hacked up a sparse patch that looks for the pattern of
unsigned casts of a (bit) negation to a wider type, and there's a fair
number of them.

Now, it may well be that my sparse hack (and it really is a hack) is a
broken piece of crap, but from a quick look the warnings it gives look
reasonable.

And there's quite a lot of them. Even in my (fairly small) config I
use on my desktop. And the first warnings I see are in x86 code:

     arch/x86/kernel/traps.c:405:16: warning: implicit unsigned
widening cast of a '~' expression
     arch/x86/kernel/cpu/perf_event_p4.c:912:15: warning: implicit
unsigned widening cast of a '~' expression

that particular one is something that has an *explicit* cast to "u64",
and then it does binary 'and' operations with these things that are of
a 32-bit unsigned type with a binary not in front of them. IOW, the
types in that expression are *very* confused.

Here's a ext4 code snippet that looks like an actual bug (but seems to
only hit read-ahead):

     ext4_fsblk_t b, block;

     b = block & ~(EXT4_SB(sb)->s_inode_readahead_blks-1);

where "b" actually ends up having the upper bits cleared, because the
s_inode_readahead_blks thing is an unsigned int, so you're masking off
not just the low bits, but the high bits too. Ted? Of course, it's
just read-ahead, so it probably doesn't matter, but.

We have a number of generic code examples where this kind of thing
seems harmless:

                 *vm_flags &= ~VM_MERGEABLE;

(we only have flags in the low 32 bits, and the only reason we get
warnings for VM_MERGEABLE is because 0x80000000 is an implicitly
unsigned constant, while 0x40000000 is *not*), or

     kernel/trace/trace.c:2910:32: warning: implicit unsigned widening
cast of a '~' expression

where "trace_flags" is "unsigned long" and "mask" is "unsigned int",
and the expression

     trace_flags &= ~mask;

actually clears the upper 32 bits too, but presumably they are always
clear anyway so we don't *really care. But it's an example of code
that is potentially very subtly dangerous.

Now, a lot of the other warnings I get seem to be more benign - the
networking code results in a lot of these because of code like this:

   #define NLMSG_ALIGNTO      4U
   #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )

which technically has the same problem if "len" is 64-bit (which
sizeof() is on x86-64), but we don't really *care* because it turns
out that the sizeof values will always have the high bits clear
*anyway*. So I'm not sure the hacky sparse warning is useful, because
my code isn't smart enough to figure out when this kind of widening
cast is a problem, and when it isn't.

That said, I'm cc'ing David and netdev too, just in case. There is
likely some *reason* why it uses an "unsigned int" for a constant that
is then commonly expanded with a binary "not" and the upper bits end
up being surprising. So this thing doesn't look like a bug, but it
does cause these warnings:

     net/netlink/af_netlink.c:1889:38: warning: implicit unsigned
widening cast of a '~' expression

and maybe the networking people care about this and maybe they don't.

(It turns out that any use of "UINT_MAX" for a "long" value also
results in this warning, because we define it as "~0ul", so there are
other cases of spurious things where we *intentionally* drop the high
bits).

ANYWAY.

Only a few of the warnings looked like they might be bugs, but I'm
attaching my sparse patch here in case somebody wants to play with the
hacky thing..

                           Linus

--001a11c18aa4608aca04dafc30f0
Content-Type: application/octet-stream; name="sparse.diff"
Content-Disposition: attachment; filename="sparse.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hfubv9hj1

IGNvbXBpbGUtaTM4Ni5jIHwgMTAgLS0tLS0tLS0tLQogZXZhbHVhdGUuYyAgICAgfCAzMCArKysr
KysrKysrKysrKysrKysrKysrKysrLS0tLS0KIHNob3ctcGFyc2UuYyAgIHwgIDkgLS0tLS0tLS0t
CiBzeW1ib2wuaCAgICAgICB8ICAxICsKIDQgZmlsZXMgY2hhbmdlZCwgMjYgaW5zZXJ0aW9ucygr
KSwgMjQgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvY29tcGlsZS1pMzg2LmMgYi9jb21waWxl
LWkzODYuYwppbmRleCBiNDcwOTUyNTIwNTMuLjMxZDNkYmNhMTA2MCAxMDA2NDQKLS0tIGEvY29t
cGlsZS1pMzg2LmMKKysrIGIvY29tcGlsZS1pMzg2LmMKQEAgLTE3Niw3ICsxNzYsNiBAQCBzdGF0
aWMgY29uc3QgY2hhciAqY3VycmVudF9zZWN0aW9uOwogc3RhdGljIHZvaWQgZW1pdF9jb21tZW50
KGNvbnN0IGNoYXIgKiBmbXQsIC4uLikgRk9STUFUX0FUVFIoMSk7CiBzdGF0aWMgdm9pZCBlbWl0
X21vdmUoc3RydWN0IHN0b3JhZ2UgKnNyYywgc3RydWN0IHN0b3JhZ2UgKmRlc3QsCiAJCSAgICAg
IHN0cnVjdCBzeW1ib2wgKmN0eXBlLCBjb25zdCBjaGFyICpjb21tZW50KTsKLXN0YXRpYyBpbnQg
dHlwZV9pc19zaWduZWQoc3RydWN0IHN5bWJvbCAqc3ltKTsKIHN0YXRpYyBzdHJ1Y3Qgc3RvcmFn
ZSAqeDg2X2FkZHJlc3NfZ2VuKHN0cnVjdCBleHByZXNzaW9uICpleHByKTsKIHN0YXRpYyBzdHJ1
Y3Qgc3RvcmFnZSAqeDg2X3N5bWJvbF9leHByKHN0cnVjdCBzeW1ib2wgKnN5bSk7CiBzdGF0aWMg
dm9pZCB4ODZfc3ltYm9sKHN0cnVjdCBzeW1ib2wgKnN5bSk7CkBAIC0yMjUwLDE1ICsyMjQ5LDYg
QEAgc3RhdGljIHZvaWQgeDg2X3N5bWJvbF9pbml0KHN0cnVjdCBzeW1ib2wgKnN5bSkKIAlwcml2
LT5hZGRyID0gbmV3OwogfQogCi1zdGF0aWMgaW50IHR5cGVfaXNfc2lnbmVkKHN0cnVjdCBzeW1i
b2wgKnN5bSkKLXsKLQlpZiAoc3ltLT50eXBlID09IFNZTV9OT0RFKQotCQlzeW0gPSBzeW0tPmN0
eXBlLmJhc2VfdHlwZTsKLQlpZiAoc3ltLT50eXBlID09IFNZTV9QVFIpCi0JCXJldHVybiAwOwot
CXJldHVybiAhKHN5bS0+Y3R5cGUubW9kaWZpZXJzICYgTU9EX1VOU0lHTkVEKTsKLX0KLQogc3Rh
dGljIHN0cnVjdCBzdG9yYWdlICp4ODZfbGFiZWxfZXhwcihzdHJ1Y3QgZXhwcmVzc2lvbiAqZXhw
cikKIHsKIAlzdHJ1Y3Qgc3RvcmFnZSAqbmV3ID0gc3RhY2tfYWxsb2MoNCk7CmRpZmYgLS1naXQg
YS9ldmFsdWF0ZS5jIGIvZXZhbHVhdGUuYwppbmRleCA5OWRlZGI1YzViZGUuLjVjNDljOWM5MmE2
OSAxMDA2NDQKLS0tIGEvZXZhbHVhdGUuYworKysgYi9ldmFsdWF0ZS5jCkBAIC0zMSw2ICszMSwx
NSBAQCBzdHJ1Y3Qgc3ltYm9sICpjdXJyZW50X2ZuOwogc3RhdGljIHN0cnVjdCBzeW1ib2wgKmRl
Z2VuZXJhdGUoc3RydWN0IGV4cHJlc3Npb24gKmV4cHIpOwogc3RhdGljIHN0cnVjdCBzeW1ib2wg
KmV2YWx1YXRlX3N5bWJvbChzdHJ1Y3Qgc3ltYm9sICpzeW0pOwogCitpbnQgdHlwZV9pc19zaWdu
ZWQoc3RydWN0IHN5bWJvbCAqc3ltKQoreworCWlmIChzeW0tPnR5cGUgPT0gU1lNX05PREUpCisJ
CXN5bSA9IHN5bS0+Y3R5cGUuYmFzZV90eXBlOworCWlmIChzeW0tPnR5cGUgPT0gU1lNX1BUUikK
KwkJcmV0dXJuIDA7CisJcmV0dXJuICEoc3ltLT5jdHlwZS5tb2RpZmllcnMgJiBNT0RfVU5TSUdO
RUQpOworfQorCiBzdGF0aWMgc3RydWN0IHN5bWJvbCAqZXZhbHVhdGVfc3ltYm9sX2V4cHJlc3Np
b24oc3RydWN0IGV4cHJlc3Npb24gKmV4cHIpCiB7CiAJc3RydWN0IGV4cHJlc3Npb24gKmFkZHI7
CkBAIC0yODIsMTIgKzI5MSwxOCBAQCBzdGF0aWMgc3RydWN0IGV4cHJlc3Npb24gKiBjYXN0X3Rv
KHN0cnVjdCBleHByZXNzaW9uICpvbGQsIHN0cnVjdCBzeW1ib2wgKnR5cGUpCiAJICovCiAJc3dp
dGNoIChvbGQtPnR5cGUpIHsKIAljYXNlIEVYUFJfUFJFT1A6Ci0JCWlmIChvbGQtPmN0eXBlLT5i
aXRfc2l6ZSA8IHR5cGUtPmJpdF9zaXplKQorCQlpZiAob2xkLT5vcCA9PSAnficgfHwgb2xkLT5v
cCA9PSAnLScpIHsKKwkJCWlmIChvbGQtPmN0eXBlLT5iaXRfc2l6ZSA+IHR5cGUtPmJpdF9zaXpl
KSB7CisJCQkJb2xkLT5jdHlwZSA9IHR5cGU7CisJCQkJb2xkLT51bm9wID0gY2FzdF90byhvbGQt
PnVub3AsIHR5cGUpOworCQkJCXJldHVybiBvbGQ7CisJCQl9CisJCQlpZiAob2xkLT5jdHlwZS0+
Yml0X3NpemUgPT0gdHlwZS0+Yml0X3NpemUpCisJCQkJYnJlYWs7CisJCQlpZiAodHlwZV9pc19z
aWduZWQob2xkLT5jdHlwZSkpCisJCQkJYnJlYWs7CisJCQl3YXJuaW5nKG9sZC0+cG9zLCAiaW1w
bGljaXQgdW5zaWduZWQgd2lkZW5pbmcgY2FzdCBvZiBhICclYycgZXhwcmVzc2lvbiIsIG9sZC0+
b3ApOwogCQkJYnJlYWs7Ci0JCWlmIChvbGQtPm9wID09ICd+JykgewotCQkJb2xkLT5jdHlwZSA9
IHR5cGU7Ci0JCQlvbGQtPnVub3AgPSBjYXN0X3RvKG9sZC0+dW5vcCwgdHlwZSk7Ci0JCQlyZXR1
cm4gb2xkOwogCQl9CiAJCWJyZWFrOwogCkBAIC0zMTAsNiArMzI1LDcgQEAgc3RhdGljIHN0cnVj
dCBleHByZXNzaW9uICogY2FzdF90byhzdHJ1Y3QgZXhwcmVzc2lvbiAqb2xkLCBzdHJ1Y3Qgc3lt
Ym9sICp0eXBlKQogCQkvKiBub3RoaW5nICovOwogCX0KIAorCiAJZXhwciA9IGFsbG9jX2V4cHJl
c3Npb24ob2xkLT5wb3MsIEVYUFJfSU1QTElFRF9DQVNUKTsKIAlleHByLT5mbGFncyA9IG9sZC0+
ZmxhZ3M7CiAJZXhwci0+Y3R5cGUgPSB0eXBlOwpAQCAtMTc1Nyw2ICsxNzczLDEwIEBAIE5vcm1h
bDoKIAl9CiAJaWYgKGV4cHItPm9wID09ICcrJykKIAkJKmV4cHIgPSAqZXhwci0+dW5vcDsKKwll
bHNlIGlmIChleHByLT51bm9wLT50eXBlID09IEVYUFJfUFJFT1AgJiYgZXhwci0+dW5vcC0+b3Ag
PT0gZXhwci0+b3ApIHsKKwkJaWYgKGV4cHItPnVub3AtPmN0eXBlID09IGN0eXBlKQorCQkJKmV4
cHIgPSAqZXhwci0+dW5vcC0+dW5vcDsKKwl9CiAJZXhwci0+Y3R5cGUgPSBjdHlwZTsKIAlyZXR1
cm4gY3R5cGU7CiBSZXN0cjoKZGlmZiAtLWdpdCBhL3Nob3ctcGFyc2UuYyBiL3Nob3ctcGFyc2Uu
YwppbmRleCAxMzMzZTMwMWMxNTEuLmM4ZTg2NDQ3NmZhYyAxMDA2NDQKLS0tIGEvc2hvdy1wYXJz
ZS5jCisrKyBiL3Nob3ctcGFyc2UuYwpAQCAtOTMzLDE1ICs5MzMsNiBAQCBzdGF0aWMgaW50IHNo
b3dfc3ltYm9sX2luaXQoc3RydWN0IHN5bWJvbCAqc3ltKQogCXJldHVybiAwOwogfQogCi1zdGF0
aWMgaW50IHR5cGVfaXNfc2lnbmVkKHN0cnVjdCBzeW1ib2wgKnN5bSkKLXsKLQlpZiAoc3ltLT50
eXBlID09IFNZTV9OT0RFKQotCQlzeW0gPSBzeW0tPmN0eXBlLmJhc2VfdHlwZTsKLQlpZiAoc3lt
LT50eXBlID09IFNZTV9QVFIpCi0JCXJldHVybiAwOwotCXJldHVybiAhKHN5bS0+Y3R5cGUubW9k
aWZpZXJzICYgTU9EX1VOU0lHTkVEKTsKLX0KLQogc3RhdGljIGludCBzaG93X2Nhc3RfZXhwcihz
dHJ1Y3QgZXhwcmVzc2lvbiAqZXhwcikKIHsKIAlzdHJ1Y3Qgc3ltYm9sICpvbGRfdHlwZSwgKm5l
d190eXBlOwpkaWZmIC0tZ2l0IGEvc3ltYm9sLmggYi9zeW1ib2wuaAppbmRleCAxZTc0NTc5OWE4
ZDAuLjY5MjhmYWY0ZmVjNiAxMDA2NDQKLS0tIGEvc3ltYm9sLmgKKysrIGIvc3ltYm9sLmgKQEAg
LTM4OSw1ICszODksNiBAQCBleHRlcm4gaW50IGlzX3B0cl90eXBlKHN0cnVjdCBzeW1ib2wgKik7
CiAKIHZvaWQgY3JlYXRlX2ZvdWxlZChzdHJ1Y3Qgc3ltYm9sICp0eXBlKTsKIHN0cnVjdCBzeW1i
b2wgKmJlZm91bChzdHJ1Y3Qgc3ltYm9sICp0eXBlKTsKK2ludCB0eXBlX2lzX3NpZ25lZChzdHJ1
Y3Qgc3ltYm9sICpzeW0pOwogCiAjZW5kaWYgLyogU1lNQk9MX0ggKi8K
--001a11c18aa4608aca04dafc30f0--
