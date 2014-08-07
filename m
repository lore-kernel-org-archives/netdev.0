From: Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Subject: [PATCH 0/5] fix error return code
Date: Thu,  7 Aug 2014 14:49:04 +0200
Message-ID: <1407415749-19978-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
 kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
Return-path: <kexec-bounces+glkk-kexec=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/kexec>,
 <mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/kexec/>
List-Post: <mailto:kexec-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/kexec>,
 <mailto:kexec-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "kexec" <kexec-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: kexec-bounces+glkk-kexec=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The complate semantic patch that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
// identify a function that returns a negative return value at least once.
@ok exists@
identifier f,ret,i;
expression e;
constant c;
@@

f(...) {
... when any
(
return -c@i;
|
ret = -c@i;
... when != ret = e
return ret;
|
if (ret < 0) { ... return ret; }
)
... when any
}

// identify a case where the return variable is set to a non-negative value
// and then returned in error-handling code
@r exists@
identifier ret,ok.f,fn;
expression e1,e2,e3,e4,e5,e6,x;
statement S,S1;
position p1,p2,p3;
@@

f(...) {
... when any
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != \(ret = e1\|ret++\|ret--\|ret+=e1\|ret-=e1\)
    when != &ret
    when any
(
 if (<+... ret = e5 ...+>) S1
|
 if (<+... &ret ...+>) S1
|
if@p2(<+...x = fn(...)...+>)
 {
  ... when != ret = e6
      when forall
 return@p3 ret;
}
|
break;
|
x = fn(...)
... when != \(ret = e4\|ret++\|ret--\|ret+=e4\|ret-=e4\)
    when != &ret
(
 if (<+... ret = e3 ...+>) S
|
 if (<+... &ret ...+>) S
|
if@p2(<+...\(x != 0\|x < 0\|x == NULL\|IS_ERR(x)\)...+>)
 {
  ... when != ret = e2
      when forall
 return@p3 ret;
}
)
)
... when any
}

@printer depends on r@
position p;
identifier ok.f,pr;
constant char [] c;
@@

f(...) { <...pr@p(...,c,...)...> }

@bad0 exists@
identifier r.ret,ok.f,g != {ERR_PTR,IS_ERR};
position p != printer.p;
@@

f(...) { ... when any
g@p(...,ret,...)
... when any
 }

// ignore the above if there is some path where the variable is set to
// something else
@bad depends on !bad0 exists@
position r.p1,r.p2;
statement S1,S2;
identifier r.ret;
expression e1;
@@

(
if@p1 (\(ret < 0\|ret != 0\)) S1
|
ret@p1 = 0
)
... when any
 \(ret = e1\|ret++\|ret--\|ret+=e1\|ret-=e1\|&ret\)
... when any
if@p2(...) S2

@bad1 depends on !bad0 && !bad exists@
position r.p2;
statement S2;
identifier r.ret;
expression e1;
constant c;
@@

ret = -c
... when != \(ret = e1\|ret++\|ret--\|ret+=e1\|ret-=e1\)
    when != &ret
    when any
if@p2(...) S2

// likewise ignore it if there has been an intervening return
@bad2 depends on !bad0 && !bad && !bad1 exists@
position r.p1,r.p2;
identifier r.ret;
expression e1;
statement S2;
constant c;
@@

ret@p1 = 0
... when != if (...) { ... ret = e1 ... return ret; }
    when != if (...) { ... return -c; }
    when any
if@p2(...) S2


@script:python depends on !bad0 && !bad && !bad1 && !bad2@
p1 << r.p1;
p2 << r.p2;
p3 << r.p3;
@@

cocci.print_main("",p1)
cocci.print_secs("",p2)
cocci.print_secs("",p3)
// </smpl>
