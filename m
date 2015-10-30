From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for
 sockets in accept(3)
Date: Fri, 30 Oct 2015 16:52:41 -0700
Message-ID: <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
References: <20151028223330.GD22011@ZenIV.linux.org.uk>
	<1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151029001532.GE22011@ZenIV.linux.org.uk>
	<1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151029041611.GF22011@ZenIV.linux.org.uk>
	<1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	<20151030210215.GI22011@ZenIV.linux.org.uk>
	<CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
	<CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
	<20151030223317.GK22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e0111bc568ce35e05235b1fda
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:32893 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbbJ3Xwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 19:52:42 -0400
In-Reply-To: <20151030223317.GK22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e0111bc568ce35e05235b1fda
Content-Type: text/plain; charset=UTF-8

On Fri, Oct 30, 2015 at 3:33 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Fri, Oct 30, 2015 at 02:50:46PM -0700, Linus Torvalds wrote:
>
>> Anyway. This is a pretty simple patch, and I actually think that we
>> could just get rid of the "next_fd" logic entirely with this. That
>> would make this *patch* be more complicated, but it would make the
>> resulting *code* be simpler.
>
> Dropping next_fd would screw you in case of strictly sequential allocations...

I don't think it would matter in real life, since I don't really think
you have lots of fd's with strictly sequential behavior.

That said, the trivial "open lots of fds" benchmark would show it, so
I guess we can just keep it. The next_fd logic is not expensive or
complex, after all.

> Your point re power-of-two allocations is well-taken, but then I'm not
> sure that kzalloc() is good enough here.

Attached is an updated patch that just uses the regular bitmap
allocator and extends it to also have the bitmap of bitmaps. It
actually simplifies the patch, so I guess it's better this way.

Anyway, I've tested it all a bit more, and for a trivial worst-case
stress program that explicitly kills the next_fd logic by doing

    for (i = 0; i < 1000000; i++) {
        close(3);
        dup2(0,3);
        if (dup(0))
            break;
    }

it takes it down from roughly 10s to 0.2s. So the patch is quite
noticeable on that kind of pattern.

NOTE! You'll obviously need to increase your limits to actually be
able to do the above with lots of file descriptors.

I ran Eric's test-program too, and find_next_zero_bit() dropped to a
fraction of a percent. It's not entirely gone, but it's down in the
noise.

I really suspect this patch is "good enough" in reality, and I would
*much* rather do something like this than add a new non-POSIX flag
that people have to update their binaries for. I agree with Eric that
*some* people will do so, but it's still the wrong thing to do. Let's
just make performance with the normal semantics be good enough that we
don't need to play odd special games.

Eric?

                       Linus

--089e0111bc568ce35e05235b1fda
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_igebeid20

IGZzL2ZpbGUuYyAgICAgICAgICAgICAgIHwgMzkgKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKystLS0tCiBpbmNsdWRlL2xpbnV4L2ZkdGFibGUuaCB8ICAyICsrCiAyIGZpbGVzIGNo
YW5nZWQsIDM3IGluc2VydGlvbnMoKyksIDQgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZnMv
ZmlsZS5jIGIvZnMvZmlsZS5jCmluZGV4IDZjNjcyYWQzMjllOS4uNmY2ZWIyYjAzYWY1IDEwMDY0
NAotLS0gYS9mcy9maWxlLmMKKysrIGIvZnMvZmlsZS5jCkBAIC01Niw2ICs1Niw5IEBAIHN0YXRp
YyB2b2lkIGZyZWVfZmR0YWJsZV9yY3Uoc3RydWN0IHJjdV9oZWFkICpyY3UpCiAJX19mcmVlX2Zk
dGFibGUoY29udGFpbmVyX29mKHJjdSwgc3RydWN0IGZkdGFibGUsIHJjdSkpOwogfQogCisjZGVm
aW5lIEJJVEJJVF9OUihucikJQklUU19UT19MT05HUyhCSVRTX1RPX0xPTkdTKG5yKSkKKyNkZWZp
bmUgQklUQklUX1NJWkUobnIpCShCSVRCSVRfTlIobnIpICogc2l6ZW9mKGxvbmcpKQorCiAvKgog
ICogRXhwYW5kIHRoZSBmZHNldCBpbiB0aGUgZmlsZXNfc3RydWN0LiAgQ2FsbGVkIHdpdGggdGhl
IGZpbGVzIHNwaW5sb2NrCiAgKiBoZWxkIGZvciB3cml0ZS4KQEAgLTc3LDYgKzgwLDExIEBAIHN0
YXRpYyB2b2lkIGNvcHlfZmR0YWJsZShzdHJ1Y3QgZmR0YWJsZSAqbmZkdCwgc3RydWN0IGZkdGFi
bGUgKm9mZHQpCiAJbWVtc2V0KChjaGFyICopKG5mZHQtPm9wZW5fZmRzKSArIGNweSwgMCwgc2V0
KTsKIAltZW1jcHkobmZkdC0+Y2xvc2Vfb25fZXhlYywgb2ZkdC0+Y2xvc2Vfb25fZXhlYywgY3B5
KTsKIAltZW1zZXQoKGNoYXIgKikobmZkdC0+Y2xvc2Vfb25fZXhlYykgKyBjcHksIDAsIHNldCk7
CisKKwljcHkgPSBCSVRCSVRfU0laRShvZmR0LT5tYXhfZmRzKTsKKwlzZXQgPSBCSVRCSVRfU0la
RShuZmR0LT5tYXhfZmRzKSAtIGNweTsKKwltZW1jcHkobmZkdC0+ZnVsbF9mZHNfYml0cywgb2Zk
dC0+ZnVsbF9mZHNfYml0cywgY3B5KTsKKwltZW1zZXQoY3B5KyhjaGFyICopbmZkdC0+ZnVsbF9m
ZHNfYml0cywgMCwgc2V0KTsKIH0KIAogc3RhdGljIHN0cnVjdCBmZHRhYmxlICogYWxsb2NfZmR0
YWJsZSh1bnNpZ25lZCBpbnQgbnIpCkBAIC0xMTUsMTIgKzEyMywxNCBAQCBzdGF0aWMgc3RydWN0
IGZkdGFibGUgKiBhbGxvY19mZHRhYmxlKHVuc2lnbmVkIGludCBucikKIAlmZHQtPmZkID0gZGF0
YTsKIAogCWRhdGEgPSBhbGxvY19mZG1lbShtYXhfdChzaXplX3QsCi0JCQkJIDIgKiBuciAvIEJJ
VFNfUEVSX0JZVEUsIEwxX0NBQ0hFX0JZVEVTKSk7CisJCQkJIDIgKiBuciAvIEJJVFNfUEVSX0JZ
VEUgKyBCSVRCSVRfU0laRShuciksIEwxX0NBQ0hFX0JZVEVTKSk7CiAJaWYgKCFkYXRhKQogCQln
b3RvIG91dF9hcnI7CiAJZmR0LT5vcGVuX2ZkcyA9IGRhdGE7CiAJZGF0YSArPSBuciAvIEJJVFNf
UEVSX0JZVEU7CiAJZmR0LT5jbG9zZV9vbl9leGVjID0gZGF0YTsKKwlkYXRhICs9IG5yIC8gQklU
U19QRVJfQllURTsKKwlmZHQtPmZ1bGxfZmRzX2JpdHMgPSBkYXRhOwogCiAJcmV0dXJuIGZkdDsK
IApAQCAtMjI5LDE0ICsyMzksMTggQEAgc3RhdGljIGlubGluZSB2b2lkIF9fY2xlYXJfY2xvc2Vf
b25fZXhlYyhpbnQgZmQsIHN0cnVjdCBmZHRhYmxlICpmZHQpCiAJX19jbGVhcl9iaXQoZmQsIGZk
dC0+Y2xvc2Vfb25fZXhlYyk7CiB9CiAKLXN0YXRpYyBpbmxpbmUgdm9pZCBfX3NldF9vcGVuX2Zk
KGludCBmZCwgc3RydWN0IGZkdGFibGUgKmZkdCkKK3N0YXRpYyBpbmxpbmUgdm9pZCBfX3NldF9v
cGVuX2ZkKHVuc2lnbmVkIGludCBmZCwgc3RydWN0IGZkdGFibGUgKmZkdCkKIHsKIAlfX3NldF9i
aXQoZmQsIGZkdC0+b3Blbl9mZHMpOworCWZkIC89IEJJVFNfUEVSX0xPTkc7CisJaWYgKCF+ZmR0
LT5vcGVuX2Zkc1tmZF0pCisJCV9fc2V0X2JpdChmZCwgZmR0LT5mdWxsX2Zkc19iaXRzKTsKIH0K
IAotc3RhdGljIGlubGluZSB2b2lkIF9fY2xlYXJfb3Blbl9mZChpbnQgZmQsIHN0cnVjdCBmZHRh
YmxlICpmZHQpCitzdGF0aWMgaW5saW5lIHZvaWQgX19jbGVhcl9vcGVuX2ZkKHVuc2lnbmVkIGlu
dCBmZCwgc3RydWN0IGZkdGFibGUgKmZkdCkKIHsKIAlfX2NsZWFyX2JpdChmZCwgZmR0LT5vcGVu
X2Zkcyk7CisJX19jbGVhcl9iaXQoZmQgLyBCSVRTX1BFUl9MT05HLCBmZHQtPmZ1bGxfZmRzX2Jp
dHMpOwogfQogCiBzdGF0aWMgaW50IGNvdW50X29wZW5fZmlsZXMoc3RydWN0IGZkdGFibGUgKmZk
dCkKQEAgLTI4MCw2ICsyOTQsNyBAQCBzdHJ1Y3QgZmlsZXNfc3RydWN0ICpkdXBfZmQoc3RydWN0
IGZpbGVzX3N0cnVjdCAqb2xkZiwgaW50ICplcnJvcnApCiAJbmV3X2ZkdC0+bWF4X2ZkcyA9IE5S
X09QRU5fREVGQVVMVDsKIAluZXdfZmR0LT5jbG9zZV9vbl9leGVjID0gbmV3Zi0+Y2xvc2Vfb25f
ZXhlY19pbml0OwogCW5ld19mZHQtPm9wZW5fZmRzID0gbmV3Zi0+b3Blbl9mZHNfaW5pdDsKKwlu
ZXdfZmR0LT5mdWxsX2Zkc19iaXRzID0gbmV3Zi0+ZnVsbF9mZHNfYml0c19pbml0OwogCW5ld19m
ZHQtPmZkID0gJm5ld2YtPmZkX2FycmF5WzBdOwogCiAJc3Bpbl9sb2NrKCZvbGRmLT5maWxlX2xv
Y2spOwpAQCAtMzIzLDYgKzMzOCw3IEBAIHN0cnVjdCBmaWxlc19zdHJ1Y3QgKmR1cF9mZChzdHJ1
Y3QgZmlsZXNfc3RydWN0ICpvbGRmLCBpbnQgKmVycm9ycCkKIAogCW1lbWNweShuZXdfZmR0LT5v
cGVuX2Zkcywgb2xkX2ZkdC0+b3Blbl9mZHMsIG9wZW5fZmlsZXMgLyA4KTsKIAltZW1jcHkobmV3
X2ZkdC0+Y2xvc2Vfb25fZXhlYywgb2xkX2ZkdC0+Y2xvc2Vfb25fZXhlYywgb3Blbl9maWxlcyAv
IDgpOworCW1lbWNweShuZXdfZmR0LT5mdWxsX2Zkc19iaXRzLCBvbGRfZmR0LT5mdWxsX2Zkc19i
aXRzLCBCSVRCSVRfU0laRShvcGVuX2ZpbGVzKSk7CiAKIAlmb3IgKGkgPSBvcGVuX2ZpbGVzOyBp
ICE9IDA7IGktLSkgewogCQlzdHJ1Y3QgZmlsZSAqZiA9ICpvbGRfZmRzKys7CkBAIC00NTQsMTAg
KzQ3MCwyNSBAQCBzdHJ1Y3QgZmlsZXNfc3RydWN0IGluaXRfZmlsZXMgPSB7CiAJCS5mZAkJPSAm
aW5pdF9maWxlcy5mZF9hcnJheVswXSwKIAkJLmNsb3NlX29uX2V4ZWMJPSBpbml0X2ZpbGVzLmNs
b3NlX29uX2V4ZWNfaW5pdCwKIAkJLm9wZW5fZmRzCT0gaW5pdF9maWxlcy5vcGVuX2Zkc19pbml0
LAorCQkuZnVsbF9mZHNfYml0cwk9IGluaXRfZmlsZXMuZnVsbF9mZHNfYml0c19pbml0LAogCX0s
CiAJLmZpbGVfbG9jawk9IF9fU1BJTl9MT0NLX1VOTE9DS0VEKGluaXRfZmlsZXMuZmlsZV9sb2Nr
KSwKIH07CiAKK3N0YXRpYyB1bnNpZ25lZCBsb25nIGZpbmRfbmV4dF9mZChzdHJ1Y3QgZmR0YWJs
ZSAqZmR0LCB1bnNpZ25lZCBsb25nIHN0YXJ0KQoreworCXVuc2lnbmVkIGxvbmcgbWF4ZmQgPSBm
ZHQtPm1heF9mZHM7CisJdW5zaWduZWQgbG9uZyBtYXhiaXQgPSBtYXhmZCAvIEJJVFNfUEVSX0xP
Tkc7CisJdW5zaWduZWQgbG9uZyBiaXRiaXQgPSBzdGFydCAvIEJJVFNfUEVSX0xPTkc7CisKKwli
aXRiaXQgPSBmaW5kX25leHRfemVyb19iaXQoZmR0LT5mdWxsX2Zkc19iaXRzLCBtYXhiaXQsIGJp
dGJpdCkgKiBCSVRTX1BFUl9MT05HOworCWlmIChiaXRiaXQgPiBtYXhmZCkKKwkJcmV0dXJuIG1h
eGZkOworCWlmIChiaXRiaXQgPiBzdGFydCkKKwkJc3RhcnQgPSBiaXRiaXQ7CisJcmV0dXJuIGZp
bmRfbmV4dF96ZXJvX2JpdChmZHQtPm9wZW5fZmRzLCBtYXhmZCwgc3RhcnQpOworfQorCiAvKgog
ICogYWxsb2NhdGUgYSBmaWxlIGRlc2NyaXB0b3IsIG1hcmsgaXQgYnVzeS4KICAqLwpAQCAtNDc2
LDcgKzUwNyw3IEBAIHJlcGVhdDoKIAkJZmQgPSBmaWxlcy0+bmV4dF9mZDsKIAogCWlmIChmZCA8
IGZkdC0+bWF4X2ZkcykKLQkJZmQgPSBmaW5kX25leHRfemVyb19iaXQoZmR0LT5vcGVuX2Zkcywg
ZmR0LT5tYXhfZmRzLCBmZCk7CisJCWZkID0gZmluZF9uZXh0X2ZkKGZkdCwgZmQpOwogCiAJLyoK
IAkgKiBOLkIuIEZvciBjbG9uZSB0YXNrcyBzaGFyaW5nIGEgZmlsZXMgc3RydWN0dXJlLCB0aGlz
IHRlc3QKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvZmR0YWJsZS5oIGIvaW5jbHVkZS9saW51
eC9mZHRhYmxlLmgKaW5kZXggNjc0ZTNlMjI2NDY1Li41Mjk1NTM1YjYwYzYgMTAwNjQ0Ci0tLSBh
L2luY2x1ZGUvbGludXgvZmR0YWJsZS5oCisrKyBiL2luY2x1ZGUvbGludXgvZmR0YWJsZS5oCkBA
IC0yNiw2ICsyNiw3IEBAIHN0cnVjdCBmZHRhYmxlIHsKIAlzdHJ1Y3QgZmlsZSBfX3JjdSAqKmZk
OyAgICAgIC8qIGN1cnJlbnQgZmQgYXJyYXkgKi8KIAl1bnNpZ25lZCBsb25nICpjbG9zZV9vbl9l
eGVjOwogCXVuc2lnbmVkIGxvbmcgKm9wZW5fZmRzOworCXVuc2lnbmVkIGxvbmcgKmZ1bGxfZmRz
X2JpdHM7CiAJc3RydWN0IHJjdV9oZWFkIHJjdTsKIH07CiAKQEAgLTU5LDYgKzYwLDcgQEAgc3Ry
dWN0IGZpbGVzX3N0cnVjdCB7CiAJaW50IG5leHRfZmQ7CiAJdW5zaWduZWQgbG9uZyBjbG9zZV9v
bl9leGVjX2luaXRbMV07CiAJdW5zaWduZWQgbG9uZyBvcGVuX2Zkc19pbml0WzFdOworCXVuc2ln
bmVkIGxvbmcgZnVsbF9mZHNfYml0c19pbml0WzFdOwogCXN0cnVjdCBmaWxlIF9fcmN1ICogZmRf
YXJyYXlbTlJfT1BFTl9ERUZBVUxUXTsKIH07CiAK
--089e0111bc568ce35e05235b1fda--
