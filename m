From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/13] make return of 0 explicit
Date: Mon, 19 May 2014 06:31:02 +0200
Message-ID: <1400473875-22228-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
 alsa-devel@alsa-project.org, linux-scsi@vger.kernel.org,
 libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
 linux-usb@vger.kernel.org, kernel-janitors@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-raid@vger.kernel.org,
 coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
 netdev@vger.kernel.org, oprofile-list@lists.sf.net, netfilter@vger.kernel.org
To: brcm80211-dev-list@broadcom.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Sometimes a local variable is used as a return value in a case where the
return value is always 0.  The result is more apparent if this variable is
just replaced by 0.  This is done by the following semantic patch, although
some cleanups may be needed. (http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
local idexpression ret;
identifier reti;
expression e;
position p;
@@

ret@reti = 0;
... when != \(ret = e\|ret &= e\|ret |= e\|ret += e\|ret -= e\|ret *= e\|ret ^= e\)
    when != \(++ret\|--ret\|ret++\|ret--\)
    when != &ret
return ret;@p

@bad1 exists@
expression e != 0;
local idexpression r.ret;
position r.p;
@@

 \(ret = e\|ret &= e\|ret |= e\|ret += e\|ret -= e\|ret *= e\|ret ^= e\|++ret\|--ret\|ret++\|ret--\|&ret\)
 ...
 return ret;@p

@bad2 exists@
identifier r.reti;
position r.p;
identifier f;
type T;
@@

f(...,T reti,...) {
 ...
 return reti;@p
}

@change depends on !bad1 && !bad2@
position r.p;
local idexpression r.ret;
identifier f;
@@

f(...) { <+...
return 
-ret
+0
;@p
...+> }

@rewrite@
local idexpression r.ret;
expression e;
position p;
identifier change.f;
@@

f(...) { <+...
 \(ret@p = e\|&ret@p\)
...+> }

@depends on change@
local idexpression r.ret;
position p != rewrite.p;
identifier change.f;
@@

f(...) { <+...
(
break;
|
ret = 0;
... when exists
ret@p
... when any
|
- ret = 0;
)
...+> }

@depends on change@
identifier r.reti;
type T;
constant C;
identifier change.f;
@@

f(...) { ... when any
-T reti = C;
 ... when != reti
     when strict
 }

@depends on change@
identifier r.reti;
type T;
identifier change.f;
@@

f(...) { ... when any
-T reti;
 ... when != reti
     when strict
 }
// </smpl>

The first four rules detect cases where only 0 reaches a return.  The
remaining rules clean up any variable initializations or declarations that
are made unnecessary by this change.
