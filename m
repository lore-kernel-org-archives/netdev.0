From: Ingo Saitz <ingo@stud.uni-hannover.de>
Subject: skb_at_tc_ingress helper breaks compilation of oot modules
Date: Wed, 20 Apr 2016 12:21:49 +0200
Message-ID: <20160420102148.GA18615@echse.zoo>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="G4iJoqBmSsgzjUCe"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1n.rrzn.uni-hannover.de ([130.75.2.107]:48465 "EHLO
	mailout1n.rrzn.uni-hannover.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932188AbcDTK1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 06:27:07 -0400
Received: from echse.zoo (dslb-084-056-223-182.084.056.pools.vodafone-ip.de [84.56.223.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mailout1n.rrzn.uni-hannover.de (Postfix) with ESMTPSA id 120D91056006
	for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 12:21:49 +0200 (CEST)
Received: from ingo by echse.zoo with local (Exim 4.87)
	(envelope-from <ingo@echse.zoo>)
	id 1aspGX-0004tF-28
	for netdev@vger.kernel.org; Wed, 20 Apr 2016 12:21:49 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

In Linux 4.5, when CONFIG_NET_CLS_ACT is defined, compilation of out of
tree modules breaks with undeclared functions/constants. The culprit is:

commit fdc5432a7b44ab7de17141beec19d946b9344e91
Author: Daniel Borkmann <daniel@iogearbox.net>
Date:   Thu Jan 7 15:50:22 2016 +0100

    net, sched: add skb_at_tc_ingress helper

which uses G_TC_AT and AT_INGRESS but only includes linux/pkt_cls.h,
which does not include these #defines for oot builds. Unfortunately I'm
not sure what the correct fix is, maybe the uapi folks could help, but i
attached a simple testcase and build log (Makefile is straight from
kernelnewbies).

    Ingo
-- 
 ╭─╮  Kennedy's Lemma:
╭│───╮  If you can parse Perl, you can solve the Halting Problem.
│╰─│─╯
╰──╯  http://www.perlmonks.org/?node_id=663393

--G4iJoqBmSsgzjUCe
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="fail.c"

#include <net/ipv6.h>

--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=Makefile

obj-m := fail.o

all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=utf-8
Content-Disposition: attachment; filename="make.log"
Content-Transfer-Encoding: 8bit

make -C /lib/modules/4.5.0-pinguin20160314/build M=/home/ingo/src/linux/pkt_cls-bug modules
make[1]: Entering directory '/usr/src/linux-headers-4.5.0-pinguin20160314'
  CC [M]  /home/ingo/src/linux/pkt_cls-bug/fail.o
In file included from include/linux/filter.h:16:0,
                 from include/net/sock.h:64,
                 from include/linux/tcp.h:22,
                 from include/linux/ipv6.h:72,
                 from include/net/ipv6.h:16,
                 from /home/ingo/src/linux/pkt_cls-bug/fail.c:1:
include/net/sch_generic.h: In function ‘skb_at_tc_ingress’:
include/net/sch_generic.h:413:9: error: implicit declaration of function ‘G_TC_AT’ [-Werror=implicit-function-declaration]
  return G_TC_AT(skb->tc_verd) & AT_INGRESS;
         ^
include/net/sch_generic.h:413:33: error: ‘AT_INGRESS’ undeclared (first use in this function)
  return G_TC_AT(skb->tc_verd) & AT_INGRESS;
                                 ^
include/net/sch_generic.h:413:33: note: each undeclared identifier is reported only once for each function it appears in
cc1: some warnings being treated as errors
scripts/Makefile.build:264: recipe for target '/home/ingo/src/linux/pkt_cls-bug/fail.o' failed
make[2]: *** [/home/ingo/src/linux/pkt_cls-bug/fail.o] Error 1
Makefile:1391: recipe for target '_module_/home/ingo/src/linux/pkt_cls-bug' failed
make[1]: *** [_module_/home/ingo/src/linux/pkt_cls-bug] Error 2
make[1]: Leaving directory '/usr/src/linux-headers-4.5.0-pinguin20160314'
Makefile:4: recipe for target 'all' failed
make: *** [all] Error 2

--G4iJoqBmSsgzjUCe--
