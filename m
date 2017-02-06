From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/kcm: WARNING in kcm_write_msgs
Date: Mon, 6 Feb 2017 15:46:29 -0800
Message-ID: <CAM_iQpWHFKLSOQ1157cweEWhV4aSw516dJ+=pmBHhhV27EsUeQ@mail.gmail.com>
References: <CACT4Y+YSSKXzmJQ2J6nMCjD_32rgoqgLYkUjVGz8YswK1Uquvw@mail.gmail.com>
 <CACT4Y+Y0m=-QP0taQqq3P2rwERrMEv-ntwk30eEbk+dDL0bPJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1145b04ad1a0710547e53e5d
Cc: David Miller <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Y0m=-QP0taQqq3P2rwERrMEv-ntwk30eEbk+dDL0bPJg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a1145b04ad1a0710547e53e5d
Content-Type: text/plain; charset=UTF-8

On Mon, Feb 6, 2017 at 4:43 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> [resending as plain text]
>
> Hello,
>
> The following program triggers WARNING in kcm_write_msgs:
>
> WARNING: CPU: 3 PID: 2936 at net/kcm/kcmsock.c:627
> kcm_write_msgs+0x12e3/0x1b90 net/kcm/kcmsock.c:627
> CPU: 3 PID: 2936 Comm: a.out Not tainted 4.10.0-rc6+ #209
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15 [inline]
>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>  panic+0x1fb/0x412 kernel/panic.c:179
>  __warn+0x1c4/0x1e0 kernel/panic.c:539
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:582
>  kcm_write_msgs+0x12e3/0x1b90 net/kcm/kcmsock.c:627
>  kcm_sendmsg+0x163a/0x2200 net/kcm/kcmsock.c:1029
>  sock_sendmsg_nosec net/socket.c:635 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:645
>  sock_write_iter+0x326/0x600 net/socket.c:848
>  new_sync_write fs/read_write.c:499 [inline]
>  __vfs_write+0x483/0x740 fs/read_write.c:512
>  vfs_write+0x187/0x530 fs/read_write.c:560
>  SYSC_write fs/read_write.c:607 [inline]
>  SyS_write+0xfb/0x230 fs/read_write.c:599
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
[...]
>   syscall(__NR_write, sock2, 0x208aaf27ul, 0x0ul);

Looks like len == 0 case is not handled correctly in kcm_sendmsg().
The attached patch fixes it, but I am not sure if it is correct in all
cases yet, the logic is complicated.

--001a1145b04ad1a0710547e53e5d
Content-Type: text/plain; charset=US-ASCII; name="kcm.diff"
Content-Disposition: attachment; filename="kcm.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iyuqwwpk0

ZGlmZiAtLWdpdCBhL25ldC9rY20va2Ntc29jay5jIGIvbmV0L2tjbS9rY21zb2NrLmMKaW5kZXgg
N2UwOGE0ZC4uNjRmMGU4NSAxMDA2NDQKLS0tIGEvbmV0L2tjbS9rY21zb2NrLmMKKysrIGIvbmV0
L2tjbS9rY21zb2NrLmMKQEAgLTkyOSwyMyArOTI5LDI1IEBAIHN0YXRpYyBpbnQga2NtX3NlbmRt
c2coc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IG1zZ2hkciAqbXNnLCBzaXplX3QgbGVuKQog
CQkJZ290byBvdXRfZXJyb3I7CiAJfQogCi0JLyogTmV3IG1lc3NhZ2UsIGFsbG9jIGhlYWQgc2ti
ICovCi0JaGVhZCA9IGFsbG9jX3NrYigwLCBzay0+c2tfYWxsb2NhdGlvbik7Ci0Jd2hpbGUgKCFo
ZWFkKSB7Ci0JCWtjbV9wdXNoKGtjbSk7Ci0JCWVyciA9IHNrX3N0cmVhbV93YWl0X21lbW9yeShz
aywgJnRpbWVvKTsKLQkJaWYgKGVycikKLQkJCWdvdG8gb3V0X2Vycm9yOwotCisJaWYgKG1zZ19k
YXRhX2xlZnQobXNnKSkgeworCQkvKiBOZXcgbWVzc2FnZSwgYWxsb2MgaGVhZCBza2IgKi8KIAkJ
aGVhZCA9IGFsbG9jX3NrYigwLCBzay0+c2tfYWxsb2NhdGlvbik7Ci0JfQorCQl3aGlsZSAoIWhl
YWQpIHsKKwkJCWtjbV9wdXNoKGtjbSk7CisJCQllcnIgPSBza19zdHJlYW1fd2FpdF9tZW1vcnko
c2ssICZ0aW1lbyk7CisJCQlpZiAoZXJyKQorCQkJCWdvdG8gb3V0X2Vycm9yOwogCi0Jc2tiID0g
aGVhZDsKKwkJCWhlYWQgPSBhbGxvY19za2IoMCwgc2stPnNrX2FsbG9jYXRpb24pOworCQl9CiAK
LQkvKiBTZXQgaXBfc3VtbWVkIHRvIENIRUNLU1VNX1VOTkVDRVNTQVJZIHRvIGF2b2lkIGNhbGxp
bmcKLQkgKiBjc3VtX2FuZF9jb3B5X2Zyb21faXRlciBmcm9tIHNrYl9kb19jb3B5X2RhdGFfbm9j
YWNoZS4KLQkgKi8KLQlza2ItPmlwX3N1bW1lZCA9IENIRUNLU1VNX1VOTkVDRVNTQVJZOworCQlz
a2IgPSBoZWFkOworCisJCS8qIFNldCBpcF9zdW1tZWQgdG8gQ0hFQ0tTVU1fVU5ORUNFU1NBUlkg
dG8gYXZvaWQgY2FsbGluZworCQkgKiBjc3VtX2FuZF9jb3B5X2Zyb21faXRlciBmcm9tIHNrYl9k
b19jb3B5X2RhdGFfbm9jYWNoZS4KKwkJICovCisJCXNrYi0+aXBfc3VtbWVkID0gQ0hFQ0tTVU1f
VU5ORUNFU1NBUlk7CisJfQogCiBzdGFydDoKIAl3aGlsZSAobXNnX2RhdGFfbGVmdChtc2cpKSB7
CkBAIC0xMDE4LDEwICsxMDIwLDEyIEBAIHN0YXRpYyBpbnQga2NtX3NlbmRtc2coc3RydWN0IHNv
Y2tldCAqc29jaywgc3RydWN0IG1zZ2hkciAqbXNnLCBzaXplX3QgbGVuKQogCWlmIChlb3IpIHsK
IAkJYm9vbCBub3RfYnVzeSA9IHNrYl9xdWV1ZV9lbXB0eSgmc2stPnNrX3dyaXRlX3F1ZXVlKTsK
IAotCQkvKiBNZXNzYWdlIGNvbXBsZXRlLCBxdWV1ZSBpdCBvbiBzZW5kIGJ1ZmZlciAqLwotCQlf
X3NrYl9xdWV1ZV90YWlsKCZzay0+c2tfd3JpdGVfcXVldWUsIGhlYWQpOwotCQlrY20tPnNlcV9z
a2IgPSBOVUxMOwotCQlLQ01fU1RBVFNfSU5DUihrY20tPnN0YXRzLnR4X21zZ3MpOworCQlpZiAo
aGVhZCkgeworCQkJLyogTWVzc2FnZSBjb21wbGV0ZSwgcXVldWUgaXQgb24gc2VuZCBidWZmZXIg
Ki8KKwkJCV9fc2tiX3F1ZXVlX3RhaWwoJnNrLT5za193cml0ZV9xdWV1ZSwgaGVhZCk7CisJCQlr
Y20tPnNlcV9za2IgPSBOVUxMOworCQkJS0NNX1NUQVRTX0lOQ1Ioa2NtLT5zdGF0cy50eF9tc2dz
KTsKKwkJfQogCiAJCWlmIChtc2ctPm1zZ19mbGFncyAmIE1TR19CQVRDSCkgewogCQkJa2NtLT50
eF93YWl0X21vcmUgPSB0cnVlOwo=
--001a1145b04ad1a0710547e53e5d--
