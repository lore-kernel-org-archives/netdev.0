From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/11] use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:14:56 +0100
Message-ID: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	users@rt2x00.serialmonkey.com
To: ath9k-devel@lists.ath9k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
used when each argument is an array within a structure that contains at
least two bytes of data beyond the array.

The semantic patch that makes this change is as follows.  To give
moderately good results, this semantic patch requires the spatch options
--recursive-includes and --relax-include-path.  These options make spatch
quite slow.  The results are also very incomplete.  In particular, there is
no result if the structure definition cannot be found or if one of the
arguments is a pointer.  The ocaml code prints some information justifying
the transformation.

// <smpl>
@pre@
expression *e;
position p;
@@

ether_addr_equal@p(...,e,...)

@r@
identifier T;
struct T eth;
identifier fld;
identifier T1;
struct T1 eth1;
identifier fld1;
position p!=pre.p;
@@

ether_addr_equal@p(eth.fld, eth1.fld1)

@ok@
identifier r.T;
type t1, t2;
identifier r.fld, fld2;
position p;
@@

struct T@p { ...
    t1 fld[...];
    t2 fld2;
    ...
  };

@ok1@
identifier r.T1;
type t1, t2;
identifier r.fld1, fld2;
position p1;
@@

struct T1@p1 { ...
    t1 fld1[...];
    t2 fld2;
    ...
  };

@script:ocaml@
rp << r.p;
okp << ok.p;
okp1 << ok1.p1;
t << r.T;
t1 << r.T1;
@@

let rp = List.hd rp in
let okp = List.hd okp in
let okp1 = List.hd okp1 in
Printf.printf "## %s: struct %s defined in %s\n" rp.file t okp.file;
Printf.printf "## %s: struct %s defined in %s\n" rp.file t1 okp1.file;
flush stdout

@depends on ok && ok1@
position r.p;
@@

-ether_addr_equal@p
+ether_addr_equal_64bits
  (...)
// </smpl>
