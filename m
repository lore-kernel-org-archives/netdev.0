From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Sun, 26 Sep 2004 17:07:59 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409261611230.8973@u.domain.uli>
References: <E1CBYCg-0000RG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-1969527934-1096207679=:8973"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CBYCg-0000RG-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-1969527934-1096207679=:8973
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	attaching version with fib_alias ordered by TOS ...

On Sun, 26 Sep 2004, Herbert Xu wrote:

> >        here prev_fa can be NULL but we require to stop at fa.
> > It happens when we are creating first entry in our subchain.
>
> If fa->fa_tos < tos, then we should add the new entry before fa.

	True, but in your patch2 you return fa after
list_for_each_entry which is not valid when the loop terminates.
Just change it to return the fa into the loop.

> If prev_fa is not NULL, then adding after prev_fa is obviously
> correct.  If prev_fa is NULL, the caller will add it after the

	May be there are two varaints when we do not return list_head
but fa:

- "insert before": find a place to "insert before" else add in tail

- "insert after": find a place to "insert after" else add in top

	but as fib_find_alias is used also for deletion I do
not think we have many choices, we return the node to insert
before, as in the comment.

> head of the list which is also correct since fa must've been the
> first element in the list.
>
> >> +                               break;
> >>                         prev_fa = fa;
> >> +                       if (fa->fa_tos > tos)
> >> +                               continue;
> >>                         if (prio <= fa->fa_info->fib_priority)
> >>                                 break;
> >
> >        here if fa is the last one it is wrong to return prev_fa!=NULL,
> > we need to return NULL (append) because we have to append
> > new entry in our subchain (which is last in this case).
>
> I still haven't figured out what you mean here, but I've found a bug :)
> When prio < fa->fa_info->fib_priority, this returns the wrong entry.

	Yes, this is one of the original problems :) If you have the
kernel running you can try the posted test script.

> > - the return value should be used in this way: if NULL then we have
> > to append the new entry at end of list. Else, it is a fa with
>
> Not quite.  If it's NULL we add it at the *head* of the list.  We
> call list_add and not list_add_tail.  Actually your patch changes the
> list_add call to list_add_tail so your comment would be correct if your
> patch had been applied :)

        It seems there are too many wishes currently in fib_find_alias.
list_add can be used for "insert after" but fa is declared to be for
"insert before fa". I think, fib_find_alias was originally designed
to be used for "insert before fa".

> > fa_tos<desired_TOS || (fa_tos==desired_TOS && fib_priority >= desired PRIO)
> > We are going to insert the new entry before this fa (even if it is
> > not exact match, even if it is from next subchain). Saying it in
> > another way: use append only if there is no place to insert.
>
> Again this is only true if we apply your patch.  As it is find_alias
> returns (and is expected to return) the entry *before* where the new
> entry should be added.

	Yes, "insert before fa", then why list_add is used?

> Whether it *should* be before or after is obviously a deep philosophical
> question :)
>
> So here are two patches to fix the fib_priority problem.  The first one
> returns the entry before as we do now while the second one returns the
> entry afterwards.
>
> Actually, I just noticed that this philosophical question does have
> practical implications :) The list_for_each_entry_continue() loop in
> fn_hash_delete will fail if fa is the entry before the correct position.

	There are simply no alternatives :) I'm attaching version
with TOS ordering for review.

> Therefore I withdraw my endorsement for the "entry before" interpretation :)
> So patch 1 is only present for review purposes, please don't apply it.
>
> Patch 2 is good as far as I can see.  So,

	return fa in loop

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Cheers,

Regards

--
Julian Anastasov <ja@ssi.bg>
--1607745702-1969527934-1096207679=:8973
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="fib_ins3.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.58.0409261707590.8973@u.domain.uli>
Content-Description: fib_alias ordered by TOS
Content-Disposition: attachment; filename="fib_ins3.diff"

ZGlmZiAtdXIgdjIuNi45LXJjMi1iazEwL2xpbnV4L25ldC9pcHY0L2ZpYl9o
YXNoLmMgbGludXgvbmV0L2lwdjQvZmliX2hhc2guYw0KLS0tIHYyLjYuOS1y
YzItYmsxMC9saW51eC9uZXQvaXB2NC9maWJfaGFzaC5jCTIwMDQtMDktMjYg
MTY6NTI6MTEuMDAwMDAwMDAwICswMzAwDQorKysgbGludXgvbmV0L2lwdjQv
ZmliX2hhc2guYwkyMDA0LTA5LTI2IDE2OjUyOjMyLjc5MDA3MDAwOCArMDMw
MA0KQEAgLTQzOCwxNyArNDM4LDE1IEBADQogew0KIAlpZiAoZm4pIHsNCiAJ
CXN0cnVjdCBsaXN0X2hlYWQgKmhlYWQgPSAmZm4tPmZuX2FsaWFzOw0KLQkJ
c3RydWN0IGZpYl9hbGlhcyAqZmEsICpwcmV2X2ZhOw0KKwkJc3RydWN0IGZp
Yl9hbGlhcyAqZmE7DQogDQotCQlwcmV2X2ZhID0gTlVMTDsNCiAJCWxpc3Rf
Zm9yX2VhY2hfZW50cnkoZmEsIGhlYWQsIGZhX2xpc3QpIHsNCi0JCQlpZiAo
ZmEtPmZhX3RvcyAhPSB0b3MpDQorCQkJaWYgKGZhLT5mYV90b3MgPiB0b3Mp
DQogCQkJCWNvbnRpbnVlOw0KLQkJCXByZXZfZmEgPSBmYTsNCi0JCQlpZiAo
cHJpbyA8PSBmYS0+ZmFfaW5mby0+ZmliX3ByaW9yaXR5KQ0KLQkJCQlicmVh
azsNCisJCQlpZiAoZmEtPmZhX2luZm8tPmZpYl9wcmlvcml0eSA+PSBwcmlv
IHx8DQorCQkJICAgIGZhLT5mYV90b3MgPCB0b3MpDQorCQkJCXJldHVybiBm
YTsNCiAJCX0NCi0JCXJldHVybiBwcmV2X2ZhOw0KIAl9DQogCXJldHVybiBO
VUxMOw0KIH0NCkBAIC01MDUsNyArNTAzLDcgQEANCiAJICogYW5kIHdlIG5l
ZWQgdG8gYWxsb2NhdGUgYSBuZXcgb25lIG9mIHRob3NlIGFzIHdlbGwuDQog
CSAqLw0KIA0KLQlpZiAoZmEgJiYNCisJaWYgKGZhICYmIGZhLT5mYV90b3Mg
PT0gdG9zICYmDQogCSAgICBmYS0+ZmFfaW5mby0+ZmliX3ByaW9yaXR5ID09
IGZpLT5maWJfcHJpb3JpdHkpIHsNCiAJCXN0cnVjdCBmaWJfYWxpYXMgKmZh
X29yaWc7DQogDQpAQCAtNTg2LDcgKzU4NCw3IEBADQogCXdyaXRlX2xvY2tf
YmgoJmZpYl9oYXNoX2xvY2spOw0KIAlpZiAobmV3X2YpDQogCQlmaWJfaW5z
ZXJ0X25vZGUoZnosIG5ld19mKTsNCi0JbGlzdF9hZGQoJm5ld19mYS0+ZmFf
bGlzdCwNCisJbGlzdF9hZGRfdGFpbCgmbmV3X2ZhLT5mYV9saXN0LA0KIAkJ
IChmYSA/ICZmYS0+ZmFfbGlzdCA6ICZmLT5mbl9hbGlhcykpOw0KIAl3cml0
ZV91bmxvY2tfYmgoJmZpYl9oYXNoX2xvY2spOw0KIA0K

--1607745702-1969527934-1096207679=:8973--
