From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: net/core: BUG in unregister_netdevice_many
Date: Fri, 21 Apr 2017 10:25:33 -0700
Message-ID: <CA+55aFwg=OtMWmU153uM27Fwk5eVv5ZBGBA9phQqVqn3nNAy6Q@mail.gmail.com>
References: <CAAeHK+zUZMGQuW=7Qhz3EWYjh6Zwv9eMBCiMCU79QrYNWox0-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113ed55a8d60c0054db08b25
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        tcharding <me@tobin.cc>, Jiri Pirko <jiri@mellanox.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+zUZMGQuW=7Qhz3EWYjh6Zwv9eMBCiMCU79QrYNWox0-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a113ed55a8d60c0054db08b25
Content-Type: text/plain; charset=UTF-8

On Fri, Apr 21, 2017 at 5:48 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> ------------[ cut here ]------------
> kernel BUG at net/core/dev.c:6813!

Another useless BUG_ON() that

 (a) kills the machine
 (b) doesn't tell the actual useful information.

Grr.

But that BUG_ON() is ancient, and actually goes back to pre-git days.
So you do seem to have triggered some code-path that doesn't ever
happen in any normal use.

This code looks odd:

  void unregister_netdevice_many(struct list_head *head)
  {
        struct net_device *dev;

        if (!list_empty(head)) {
                rollback_registered_many(head);
                list_for_each_entry(dev, head, unreg_list)
                        net_set_todo(dev);
                list_del(head);
        }
  }

In particular the pattern of "look if list is empty, do something to
the list, and then delete the list" is a rather nasty pattern.

Why? That final "delete the list" looks like garbage to me.

Either that list is never used again - in which case the list_del() is
pointless - or it _is_ used again, in which case the list_del is
wrong.

Why is it wrong? Because "list_del()" only removes the list from the
head, but leaves the head itself untouched. So it will still end up
pointing to the list entries that we've just walked.

Now, almost every single case I looked at, the head is always a
temporary list that was created just for this
"unregister_netdevice_many()", so the code works fine, and it's a case
of "that list_del() is just pointless".

But it's a very dangerous pattern. Either the list head should be left
alone, or it should be cleaned up with list_del_init()

Anyway, because each user seems fine, and really just uses it as a
temporary list, this is not the cause of the bug.

I'm assuming that the real cause is simply that "dev->reg_state" ends
up being NETREG_UNREGISTERING or something. Maybe the BUG_ON() could
be just removed, and replaced by the previous warning about
NETREG_UNINITIALIZED.

Something like the attached (TOTALLY UNTESTED) patch.

We really shouldn't have BUG_ON()'s in the kernel, particularly for
cases that we already have error handling for and are ignoring. But
whatever.

Eric Dumazet seems to be the main person to look at this.

                  Linus

--001a113ed55a8d60c0054db08b25
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j1s3wym00

IG5ldC9jb3JlL2Rldi5jIHwgOCArKystLS0tLQogMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9u
cygrKSwgNSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvY29yZS9kZXYuYyBiL25ldC9j
b3JlL2Rldi5jCmluZGV4IDUzM2E2ZDZmNjA5Mi4uNGU1MGIyZmIzYTkwIDEwMDY0NAotLS0gYS9u
ZXQvY29yZS9kZXYuYworKysgYi9uZXQvY29yZS9kZXYuYwpAQCAtNjgwMSwxNiArNjgwMSwxNCBA
QCBzdGF0aWMgdm9pZCByb2xsYmFja19yZWdpc3RlcmVkX21hbnkoc3RydWN0IGxpc3RfaGVhZCAq
aGVhZCkKIAkJICogZm9yIGluaXRpYWxpemF0aW9uIHVud2luZC4gUmVtb3ZlIHRob3NlCiAJCSAq
IGRldmljZXMgYW5kIHByb2NlZWQgd2l0aCB0aGUgcmVtYWluaW5nLgogCQkgKi8KLQkJaWYgKGRl
di0+cmVnX3N0YXRlID09IE5FVFJFR19VTklOSVRJQUxJWkVEKSB7Ci0JCQlwcl9kZWJ1ZygidW5y
ZWdpc3Rlcl9uZXRkZXZpY2U6IGRldmljZSAlcy8lcCBuZXZlciB3YXMgcmVnaXN0ZXJlZFxuIiwK
LQkJCQkgZGV2LT5uYW1lLCBkZXYpOworCQlpZiAoV0FSTl9PTl9PTkNFKGRldi0+cmVnX3N0YXRl
ICE9IE5FVFJFR19SRUdJU1RFUkVEKSkgeworCQkJcHJpbnRrKCJ1bnJlZ2lzdGVyX25ldGRldmlj
ZTogZGV2aWNlICVzLyVwIHdhcyBub3QgcmVnaXN0ZXJlZCAoJWQpXG4iLAorCQkJCSBkZXYtPm5h
bWUsIGRldiwgZGV2LT5yZWdfc3RhdGUpOwogCi0JCQlXQVJOX09OKDEpOwogCQkJbGlzdF9kZWwo
JmRldi0+dW5yZWdfbGlzdCk7CiAJCQljb250aW51ZTsKIAkJfQogCQlkZXYtPmRpc21hbnRsZSA9
IHRydWU7Ci0JCUJVR19PTihkZXYtPnJlZ19zdGF0ZSAhPSBORVRSRUdfUkVHSVNURVJFRCk7CiAJ
fQogCiAJLyogSWYgZGV2aWNlIGlzIHJ1bm5pbmcsIGNsb3NlIGl0IGZpcnN0LiAqLwo=
--001a113ed55a8d60c0054db08b25--
