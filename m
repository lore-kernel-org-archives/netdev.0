From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: slab corruption with current -git (was Re: [git pull] vfs pile 1 (splice))
Date: Sun, 9 Oct 2016 20:41:17 -0700
Message-ID: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
References: <CA+55aFz2U83pG0v12E--nd5c6GZAUpVnT3jHuAwHCFk5XbVX0w@mail.gmail.com>
 <20161010005105.GA18349@breakpoint.cc> <f7tbmytkmtr.fsf@redhat.com> <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113d0a245ccd7b053e7a885f
Cc: Florian Westphal <fw@strlen.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jens Axboe <axboe@fb.com>, "Ted Ts'o" <tytso@mit.edu>,
        Christoph Lameter <cl@linux.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
To: Aaron Conole <aconole@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a113d0a245ccd7b053e7a885f
Content-Type: text/plain; charset=UTF-8

On Sun, Oct 9, 2016 at 7:49 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> There is one *correct* way to remove an entry from a singly linked
> list, and it looks like this:
>
>     struct entry **pp, *p;
>
>     pp = &head;
>     while ((p = *pp) != NULL) {
>         if (right_entry(p)) {
>             *pp = p->next;
>             break;
>         }
>         pp = &p->next;
>     }
>
> and that's it. Nothing else.

This COMPLETELY UNTESTED patch tries to fix the nf_hook_entry code to do this.

I repeat: it's ENTIRELY UNTESTED. I just converted the insertion and
deletion to the proper pattern, but I could easily have gotten the
insertion priority test the wrong way around entirely, for example. Or
it could simply have some other completely broken bug in it. It
compiles for me, but that's all I actually checked.

Note that the "correct way" of doing list operations also almost
inevitably is the shortest way by far, since it gets rid of all the
special cases. So the patch looks nice. It gets rid of the magic
"nf_set_hooks_head()" thing too, because once you do list following
right, the head is no different from any other pointer in the list.

So the patch stats look good:

 net/netfilter/core.c | 108 ++++++++++++++++-----------------------------------
 1 file changed, 33 insertions(+), 75 deletions(-)

but again, it's entirely *entirely* untested. Please consider this
just a "this is generally how list insert/delete operations should be
done, avoiding special cases for the first entry".

ALSO NOTE! The code assumes that the "nf_hook_mutex" locking only
protects the actual *lists*, and that the address to the list can be
looked up without holding the lock. That's generally how things are
done, and it simplifies error handling (because you can do the "there
is no such list at all" test before you do anything else. But again, I
don't actually know the code, and if there is something that actually
expands the number of lists etc that depends on that mutex, then the
list head lookup may need to be inside the lock too.

           Linus

--001a113d0a245ccd7b053e7a885f
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iu3ih4js0

IG5ldC9uZXRmaWx0ZXIvY29yZS5jIHwgMTA4ICsrKysrKysrKysrKysrKystLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLQogMSBmaWxlIGNoYW5nZWQsIDMzIGluc2VydGlvbnMoKyks
IDc1IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL25ldC9uZXRmaWx0ZXIvY29yZS5jIGIvbmV0
L25ldGZpbHRlci9jb3JlLmMKaW5kZXggYzlkOTBlYjY0MDQ2Li44MTQyNTg2NDFmY2MgMTAwNjQ0
Ci0tLSBhL25ldC9uZXRmaWx0ZXIvY29yZS5jCisrKyBiL25ldC9uZXRmaWx0ZXIvY29yZS5jCkBA
IC02NSw0OSArNjUsMjQgQEAgc3RhdGljIERFRklORV9NVVRFWChuZl9ob29rX211dGV4KTsKICNk
ZWZpbmUgbmZfZW50cnlfZGVyZWZlcmVuY2UoZSkgXAogCXJjdV9kZXJlZmVyZW5jZV9wcm90ZWN0
ZWQoZSwgbG9ja2RlcF9pc19oZWxkKCZuZl9ob29rX211dGV4KSkKIAotc3RhdGljIHN0cnVjdCBu
Zl9ob29rX2VudHJ5ICpuZl9ob29rX2VudHJ5X2hlYWQoc3RydWN0IG5ldCAqbmV0LAotCQkJCQkJ
Y29uc3Qgc3RydWN0IG5mX2hvb2tfb3BzICpyZWcpCitzdGF0aWMgc3RydWN0IG5mX2hvb2tfZW50
cnkgX19yY3UgKipuZl9ob29rX2VudHJ5X2hlYWQoc3RydWN0IG5ldCAqbmV0LCBjb25zdCBzdHJ1
Y3QgbmZfaG9va19vcHMgKnJlZykKIHsKLQlzdHJ1Y3QgbmZfaG9va19lbnRyeSAqaG9va19oZWFk
ID0gTlVMTDsKLQogCWlmIChyZWctPnBmICE9IE5GUFJPVE9fTkVUREVWKQotCQlob29rX2hlYWQg
PSBuZl9lbnRyeV9kZXJlZmVyZW5jZShuZXQtPm5mLmhvb2tzW3JlZy0+cGZdCi0JCQkJCQkgW3Jl
Zy0+aG9va251bV0pOwotCWVsc2UgaWYgKHJlZy0+aG9va251bSA9PSBORl9ORVRERVZfSU5HUkVT
UykgeworCQlyZXR1cm4gbmV0LT5uZi5ob29rc1tyZWctPnBmXStyZWctPmhvb2tudW07CisKICNp
ZmRlZiBDT05GSUdfTkVURklMVEVSX0lOR1JFU1MKKwlpZiAocmVnLT5ob29rbnVtID09IE5GX05F
VERFVl9JTkdSRVNTKSB7CiAJCWlmIChyZWctPmRldiAmJiBkZXZfbmV0KHJlZy0+ZGV2KSA9PSBu
ZXQpCi0JCQlob29rX2hlYWQgPQotCQkJCW5mX2VudHJ5X2RlcmVmZXJlbmNlKAotCQkJCQlyZWct
PmRldi0+bmZfaG9va3NfaW5ncmVzcyk7Ci0jZW5kaWYKKwkJCXJldHVybiAmcmVnLT5kZXYtPm5m
X2hvb2tzX2luZ3Jlc3M7CiAJfQotCXJldHVybiBob29rX2hlYWQ7Ci19Ci0KLS8qIG11c3QgaG9s
ZCBuZl9ob29rX211dGV4ICovCi1zdGF0aWMgdm9pZCBuZl9zZXRfaG9va3NfaGVhZChzdHJ1Y3Qg
bmV0ICpuZXQsIGNvbnN0IHN0cnVjdCBuZl9ob29rX29wcyAqcmVnLAotCQkJICAgICAgc3RydWN0
IG5mX2hvb2tfZW50cnkgKmVudHJ5KQotewotCXN3aXRjaCAocmVnLT5wZikgewotCWNhc2UgTkZQ
Uk9UT19ORVRERVY6Ci0jaWZkZWYgQ09ORklHX05FVEZJTFRFUl9JTkdSRVNTCi0JCS8qIFdlIGFs
cmVhZHkgY2hlY2tlZCBpbiBuZl9yZWdpc3Rlcl9uZXRfaG9vaygpIHRoYXQgdGhpcyBpcwotCQkg
KiB1c2VkIGZyb20gaW5ncmVzcy4KLQkJICovCi0JCXJjdV9hc3NpZ25fcG9pbnRlcihyZWctPmRl
di0+bmZfaG9va3NfaW5ncmVzcywgZW50cnkpOwogI2VuZGlmCi0JCWJyZWFrOwotCWRlZmF1bHQ6
Ci0JCXJjdV9hc3NpZ25fcG9pbnRlcihuZXQtPm5mLmhvb2tzW3JlZy0+cGZdW3JlZy0+aG9va251
bV0sCi0JCQkJICAgZW50cnkpOwotCQlicmVhazsKLQl9CisJcmV0dXJuIE5VTEw7CiB9CiAKIGlu
dCBuZl9yZWdpc3Rlcl9uZXRfaG9vayhzdHJ1Y3QgbmV0ICpuZXQsIGNvbnN0IHN0cnVjdCBuZl9o
b29rX29wcyAqcmVnKQogewotCXN0cnVjdCBuZl9ob29rX2VudHJ5ICpob29rc19lbnRyeTsKLQlz
dHJ1Y3QgbmZfaG9va19lbnRyeSAqZW50cnk7CisJc3RydWN0IG5mX2hvb2tfZW50cnkgX19yY3Ug
KipwcDsKKwlzdHJ1Y3QgbmZfaG9va19lbnRyeSAqZW50cnksICpwOwogCiAJaWYgKHJlZy0+cGYg
PT0gTkZQUk9UT19ORVRERVYpIHsKICNpZm5kZWYgQ09ORklHX05FVEZJTFRFUl9JTkdSRVNTCkBA
IC0xMTksNiArOTQsMTAgQEAgaW50IG5mX3JlZ2lzdGVyX25ldF9ob29rKHN0cnVjdCBuZXQgKm5l
dCwgY29uc3Qgc3RydWN0IG5mX2hvb2tfb3BzICpyZWcpCiAJCQlyZXR1cm4gLUVJTlZBTDsKIAl9
CiAKKwlwcCA9IG5mX2hvb2tfZW50cnlfaGVhZChuZXQsIHJlZyk7CisJaWYgKCFwcCkKKwkJcmV0
dXJuIC1FSU5WQUw7CisKIAllbnRyeSA9IGttYWxsb2Moc2l6ZW9mKCplbnRyeSksIEdGUF9LRVJO
RUwpOwogCWlmICghZW50cnkpCiAJCXJldHVybiAtRU5PTUVNOwpAQCAtMTI4LDI2ICsxMDcsMTUg
QEAgaW50IG5mX3JlZ2lzdGVyX25ldF9ob29rKHN0cnVjdCBuZXQgKm5ldCwgY29uc3Qgc3RydWN0
IG5mX2hvb2tfb3BzICpyZWcpCiAJZW50cnktPm5leHQJPSBOVUxMOwogCiAJbXV0ZXhfbG9jaygm
bmZfaG9va19tdXRleCk7Ci0JaG9va3NfZW50cnkgPSBuZl9ob29rX2VudHJ5X2hlYWQobmV0LCBy
ZWcpOwotCi0JaWYgKGhvb2tzX2VudHJ5ICYmIGhvb2tzX2VudHJ5LT5vcmlnX29wcy0+cHJpb3Jp
dHkgPiByZWctPnByaW9yaXR5KSB7Ci0JCS8qIFRoaXMgaXMgdGhlIGNhc2Ugd2hlcmUgd2UgbmVl
ZCB0byBpbnNlcnQgYXQgdGhlIGhlYWQgKi8KLQkJZW50cnktPm5leHQgPSBob29rc19lbnRyeTsK
LQkJaG9va3NfZW50cnkgPSBOVUxMOwotCX0KLQotCXdoaWxlIChob29rc19lbnRyeSAmJgotCQly
ZWctPnByaW9yaXR5ID49IGhvb2tzX2VudHJ5LT5vcmlnX29wcy0+cHJpb3JpdHkgJiYKLQkJbmZf
ZW50cnlfZGVyZWZlcmVuY2UoaG9va3NfZW50cnktPm5leHQpKSB7Ci0JCWhvb2tzX2VudHJ5ID0g
bmZfZW50cnlfZGVyZWZlcmVuY2UoaG9va3NfZW50cnktPm5leHQpOwotCX0KIAotCWlmIChob29r
c19lbnRyeSkgewotCQllbnRyeS0+bmV4dCA9IG5mX2VudHJ5X2RlcmVmZXJlbmNlKGhvb2tzX2Vu
dHJ5LT5uZXh0KTsKLQkJcmN1X2Fzc2lnbl9wb2ludGVyKGhvb2tzX2VudHJ5LT5uZXh0LCBlbnRy
eSk7Ci0JfSBlbHNlIHsKLQkJbmZfc2V0X2hvb2tzX2hlYWQobmV0LCByZWcsIGVudHJ5KTsKKwkv
KiBGaW5kIHRoZSBzcG90IGluIHRoZSBsaXN0ICovCisJd2hpbGUgKChwID0gbmZfZW50cnlfZGVy
ZWZlcmVuY2UoKnBwKSkgIT0gTlVMTCkgeworCQlpZiAocmVnLT5wcmlvcml0eSA8IHAtPm9yaWdf
b3BzLT5wcmlvcml0eSkKKwkJCWJyZWFrOworCQlwcCA9ICZwLT5uZXh0OwogCX0KKwlyY3VfYXNz
aWduX3BvaW50ZXIoZW50cnktPm5leHQsIHApOworCXJjdV9hc3NpZ25fcG9pbnRlcigqcHAsIHAp
OwogCiAJbXV0ZXhfdW5sb2NrKCZuZl9ob29rX211dGV4KTsKICNpZmRlZiBDT05GSUdfTkVURklM
VEVSX0lOR1JFU1MKQEAgLTE2MywzMyArMTMxLDIzIEBAIEVYUE9SVF9TWU1CT0wobmZfcmVnaXN0
ZXJfbmV0X2hvb2spOwogCiB2b2lkIG5mX3VucmVnaXN0ZXJfbmV0X2hvb2soc3RydWN0IG5ldCAq
bmV0LCBjb25zdCBzdHJ1Y3QgbmZfaG9va19vcHMgKnJlZykKIHsKLQlzdHJ1Y3QgbmZfaG9va19l
bnRyeSAqaG9va3NfZW50cnk7CisJc3RydWN0IG5mX2hvb2tfZW50cnkgX19yY3UgKipwcDsKKwlz
dHJ1Y3QgbmZfaG9va19lbnRyeSAqcDsKIAotCW11dGV4X2xvY2soJm5mX2hvb2tfbXV0ZXgpOwot
CWhvb2tzX2VudHJ5ID0gbmZfaG9va19lbnRyeV9oZWFkKG5ldCwgcmVnKTsKLQlpZiAoaG9va3Nf
ZW50cnkgJiYgaG9va3NfZW50cnktPm9yaWdfb3BzID09IHJlZykgewotCQluZl9zZXRfaG9va3Nf
aGVhZChuZXQsIHJlZywKLQkJCQkgIG5mX2VudHJ5X2RlcmVmZXJlbmNlKGhvb2tzX2VudHJ5LT5u
ZXh0KSk7Ci0JCWdvdG8gdW5sb2NrOwotCX0KLQl3aGlsZSAoaG9va3NfZW50cnkgJiYgbmZfZW50
cnlfZGVyZWZlcmVuY2UoaG9va3NfZW50cnktPm5leHQpKSB7Ci0JCXN0cnVjdCBuZl9ob29rX2Vu
dHJ5ICpuZXh0ID0KLQkJCW5mX2VudHJ5X2RlcmVmZXJlbmNlKGhvb2tzX2VudHJ5LT5uZXh0KTsK
LQkJc3RydWN0IG5mX2hvb2tfZW50cnkgKm5uZXh0OworCXBwID0gbmZfaG9va19lbnRyeV9oZWFk
KG5ldCwgcmVnKTsKKwlpZiAoV0FSTl9PTl9PTkNFKCFwcCkpCisJCXJldHVybjsKIAotCQlpZiAo
bmV4dC0+b3JpZ19vcHMgIT0gcmVnKSB7Ci0JCQlob29rc19lbnRyeSA9IG5leHQ7Ci0JCQljb250
aW51ZTsKKwltdXRleF9sb2NrKCZuZl9ob29rX211dGV4KTsKKwl3aGlsZSAoKHAgPSBuZl9lbnRy
eV9kZXJlZmVyZW5jZSgqcHApKSAhPSBOVUxMKSB7CisJCWlmIChwLT5vcmlnX29wcyA9PSByZWcp
IHsKKwkJCXJjdV9hc3NpZ25fcG9pbnRlcigqcHAsIHAtPm5leHQpOworCQkJYnJlYWs7CiAJCX0K
LQkJbm5leHQgPSBuZl9lbnRyeV9kZXJlZmVyZW5jZShuZXh0LT5uZXh0KTsKLQkJcmN1X2Fzc2ln
bl9wb2ludGVyKGhvb2tzX2VudHJ5LT5uZXh0LCBubmV4dCk7Ci0JCWhvb2tzX2VudHJ5ID0gbmV4
dDsKLQkJYnJlYWs7CisJCXBwID0gJnAtPm5leHQ7CiAJfQotCi11bmxvY2s6CiAJbXV0ZXhfdW5s
b2NrKCZuZl9ob29rX211dGV4KTsKLQlpZiAoIWhvb2tzX2VudHJ5KSB7CisJaWYgKCFwKSB7CiAJ
CVdBUk4oMSwgIm5mX3VucmVnaXN0ZXJfbmV0X2hvb2s6IGhvb2sgbm90IGZvdW5kIVxuIik7CiAJ
CXJldHVybjsKIAl9CkBAIC0yMDEsMTAgKzE1OSwxMCBAQCB2b2lkIG5mX3VucmVnaXN0ZXJfbmV0
X2hvb2soc3RydWN0IG5ldCAqbmV0LCBjb25zdCBzdHJ1Y3QgbmZfaG9va19vcHMgKnJlZykKIAlz
dGF0aWNfa2V5X3Nsb3dfZGVjKCZuZl9ob29rc19uZWVkZWRbcmVnLT5wZl1bcmVnLT5ob29rbnVt
XSk7CiAjZW5kaWYKIAlzeW5jaHJvbml6ZV9uZXQoKTsKLQluZl9xdWV1ZV9uZl9ob29rX2Ryb3Ao
bmV0LCBob29rc19lbnRyeSk7CisJbmZfcXVldWVfbmZfaG9va19kcm9wKG5ldCwgcCk7CiAJLyog
b3RoZXIgY3B1IG1pZ2h0IHN0aWxsIHByb2Nlc3MgbmZxdWV1ZSB2ZXJkaWN0IHRoYXQgdXNlZCBy
ZWcgKi8KIAlzeW5jaHJvbml6ZV9uZXQoKTsKLQlrZnJlZShob29rc19lbnRyeSk7CisJa2ZyZWUo
cCk7CiB9CiBFWFBPUlRfU1lNQk9MKG5mX3VucmVnaXN0ZXJfbmV0X2hvb2spOwogCg==
--001a113d0a245ccd7b053e7a885f--
