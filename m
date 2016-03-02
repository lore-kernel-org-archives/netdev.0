From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/4] tc: pedit fixes
Date: Wed,  2 Mar 2016 19:45:39 +0100
Message-ID: <1456944343-19058-1-git-send-email-phil@nwl.cc>
References: <20160302095414.45a928df@xeon-e3>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58785 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755302AbcCBSqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 13:46:03 -0500
In-Reply-To: <20160302095414.45a928df@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While implementing an implementation example for a pedit man page, I
noticed several issues with the current code. The following patch
series addreses them.

In order to validate my changes, I implemented a simple unit tester.
It requires the following hack:

--------------------------8<-----------------------------------------
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -513,6 +513,12 @@ parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, stru
                }
        }
 
+       fprintf(stderr, "mask=0x%x\n", sel.keys[0].mask);
+       fprintf(stderr, "val=0x%x\n", sel.keys[0].val);
+       fprintf(stderr, "off=0x%x\n", sel.keys[0].off);
+       fprintf(stderr, "at=0x%x\n", sel.keys[0].at);
+       fprintf(stderr, "offmask=0x%x\n", sel.keys[0].offmask);
+       fprintf(stderr, "shift=0x%x\n", sel.keys[0].shift);
        tail = NLMSG_TAIL(n);
        addattr_l(n, MAX_MSG, tca_id, NULL, 0);
        addattr_l(n, MAX_MSG, TCA_PEDIT_PARMS,&sel, sizeof(sel.sel)+sel.sel.nkeys*sizeof(struct tc_pedit_key));
--------------------------8<-----------------------------------------

With this in place, the following simple shell script can be used to
check generated permutation values:

--------------------------8<-----------------------------------------
#!/bin/bash

run_tc() {
	echo "testing $@"
	eval "$(./tc/tc filter add dev bla123 parent root u32 \
		match u32 0 0 action pedit munge $@ 2>&1 | \
		grep -e '^\(mask\|val\|off\|at\|offmask\|shift\)=')"
}

prove() { # (oval, check, ooff)
	local oval=$1
	local check=$2
	local ooff=$3
	[[ $ooff -eq $off ]] || {
		echo "Wrong offset ($off instead of $ooff)"
		#exit 1
	}
	[[ $(((oval & mask) ^ val)) -eq $check ]] || {
		echo "failed for $oval, should be $check but is 0x$(echo "obase = 16; $(((oval & mask) ^ val))" | bc)"
		echo "mask=$mask"
		echo "val=$val"
		echo "off=$off"
		echo "at=$at"
		echo "offmask=$offmask"
		echo "shift=$shift"
		#exit 1
	}
}

run_tc ip df set 0
prove 0xffffffff 0xffbfffff 4
prove 0x00400000 0x00000000 4
prove 0xffbfffff 0xffbfffff 4
prove 0x00000000 0x00000000 4

run_tc ip df set 0x40
prove 0xffffffff 0xffffffff 4
prove 0x00400000 0x00400000 4
prove 0xffbfffff 0xffffffff 4
prove 0x00000000 0x00400000 4

run_tc ip df preserve
prove 0xffffffff 0xffffffff 4
prove 0x00400000 0x00400000 4
prove 0xffbfffff 0xffbfffff 4
prove 0x00000000 0x00000000 4

run_tc ip df invert
prove 0xffffffff 0xffbfffff 4
prove 0x00400000 0x00000000 4
prove 0xffbfffff 0xffffffff 4
prove 0x00000000 0x00400000 4

run_tc ip mf set 0x20
prove 0xfffff2ff 0xfffff2ff 4
prove 0x00203000 0x00203000 4
prove 0xfadfffff 0xfaffffff 4
prove 0x00000000 0x00200000 4

run_tc ip ihl set 0x04
prove 0xffffffff 0xfffffff4 0
prove 0x00000005 0x00000004 0
prove 0xfffffff0 0xfffffff4 0
prove 0x00000000 0x00000004 0

run_tc ip tos set 0
prove 0xffffffff 0xffff00ff 0
prove 0x00002300 0x00000000 0
prove 0xffff00ff 0xffff00ff 0
prove 0x00000000 0x00000000 0

run_tc ip tos set 17
prove 0xffffffff 0xffff11ff 0
prove 0x00002300 0x00001100 0
prove 0xffff00ff 0xffff11ff 0
prove 0x00000000 0x00001100 0

run_tc ip tos invert
prove 0xffffffff 0xffff00ff 0
prove 0x00002300 0x0000DC00 0
prove 0xffff00ff 0xffffffff 0
prove 0x00000000 0x0000ff00 0

run_tc ip tos preserve
prove 0xffffffff 0xffffffff 0
prove 0x00002300 0x00002300 0
prove 0xffff00ff 0xffff00ff 0
prove 0x00000000 0x00000000 0

run_tc ip tos clear
prove 0xffffffff 0xffff00ff 0
prove 0x00002300 0x00000000 0
prove 0xffff00ff 0xffff00ff 0
prove 0x00000000 0x00000000 0

run_tc ip dport set 0
prove 0xffffffff 0x0000ffff 20
prove 0x12340000 0x00000000 20
prove 0x0000ffff 0x0000ffff 20
prove 0x00000000 0x00000000 20

run_tc ip dport set 27374
prove 0xfffff22f 0xee6af22f 20
prove 0x12340010 0xee6a0010 20
prove 0xee6aff0f 0xee6aff0f 20
prove 0xee6a0000 0xee6a0000 20

run_tc ip dport invert
prove 0xffffffff 0x0000ffff 20
prove 0x12340000 0xEDCB0000 20
prove 0x00000000 0xffff0000 20

run_tc ip dport preserve
prove 0xffffffff 0xffffffff 20
prove 0x12340000 0x12340000 20
prove 0xee6affff 0xee6affff 20
prove 0xee6a0000 0xee6a0000 20

run_tc ip dport clear
prove 0xffff3fff 0x00003fff 20
prove 0x12340030 0x00000030 20
prove 0xee6af1ff 0x0000f1ff 20
prove 0x00000000 0x00000000 20


run_tc ip src set 0.0.0.0
prove 0xffff3fff 0x00000000 12
prove 0x12340030 0x00000000 12
prove 0xee6af1ff 0x00000000 12
prove 0x00000000 0x00000000 12

run_tc ip src set 1.2.3.4
prove 0xffff3fff 0x01020304 12
prove 0x12340030 0x01020304 12
prove 0xee6af1ff 0x01020304 12
prove 0x00000000 0x01020304 12

run_tc ip src clear
prove 0xffff3fff 0x00000000 12
prove 0x12340030 0x00000000 12
prove 0xee6af1ff 0x00000000 12
prove 0x00000000 0x00000000 12

run_tc ip src preserve
prove 0xffff3fff 0xffff3fff 12
prove 0x12340030 0x12340030 12
prove 0xee6af1ff 0xee6af1ff 12
prove 0x00000000 0x00000000 12

run_tc ip src invert
prove 0xffff3fff 0x0000c000 12
prove 0x12340030 0xedcbffcf 12
prove 0xee6af1ff 0x11950e00 12
prove 0x00000000 0xffffffff 12
--------------------------8<-----------------------------------------

Changes since v1:
- rebased onto current master
- added required whitespace after comma in patch 3
- new patch 4 fixing remaining checkpatch.pl issues in tc/p_ip.c

Phil Sutter (4):
  tc: pedit: Fix layered op parsing
  tc: pedit: Fix parse_cmd()
  tc: pedit: Fix retain value for ihl adjustments
  tc/p_ip.c: Lint through checkpatch.pl

 tc/m_pedit.c | 24 ++++++++----------------
 tc/p_ip.c    | 38 ++++++++++++++++++++------------------
 2 files changed, 28 insertions(+), 34 deletions(-)

-- 
2.7.2
