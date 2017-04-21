From: <Joe.Ghalam@dell.com>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Fri, 21 Apr 2017 14:40:50 +0000
Message-ID: <1492785652578.53801@Dell.com>
References: <1492618528011.11322@Dell.com>
 <20170420125512.GA9113@gondor.apana.org.au>
 <1492704599476.84165@Dell.com>,<20170421044029.GA11695@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <davem@davemloft.net>, <Clifford.Wichmann@dell.com>,
        <netdev@vger.kernel.org>
To: <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.dell-outbound.iphmx.com ([68.232.153.90]:20953 "EHLO
        esa1.dell-outbound.iphmx.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1038603AbdDURkr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 13:40:47 -0400
In-Reply-To: <20170421044029.GA11695@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That's not true. macvlan_dellink() unregisters the queue, and macvlan_proce=
ss_broadcast() will never get called. Please note that I'm not speculating.=
 I have traced enabled on the dev_put and dev_hold, and I'm reporting a rea=
l, reproducible issue.=0A=
Her is a sequence of calls logged, when the issue happens. macvlan_process_=
broadcast() never happens.=0A=
=0A=
Apr 19 04:35:39 OS10 kernel: e101-001-0.v257: dev_put 16 dst_destroy=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 dev_get_by_index=
=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 do_ip_setsockopt=
=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 dst_alloc=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 dst_destroy=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 macvlan_broadcast=
_enqueue=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 macvlan_process_br=
oadcast=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 macvlan_broadcast=
_enqueue=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 macvlan_process_br=
oadcast=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_hold 15 macvlan_broadcast=
_enqueue    <---insert=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 16 neigh_destroy=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 15 neigh_destroy=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 14 neigh_destroy=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 13 dst_destroy=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 12 dst_destroy=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 11 __netdev_adjacent_=
dev_remove <--- macvlan_dellink()=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 10 __netdev_adjacent_=
dev_remove <--- macvlan_dellink()=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 9 neigh_parms_release=
=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 8 neigh_parms_release=
=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 7 in6_dev_finish_dest=
roy=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 6 rx_queue_release=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 5 netdev_queue_releas=
e=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 4 rollback_registered=
_many=0A=
Apr 19 04:35:41 OS10 kernel: e101-001-0.v257: dev_put 3 free_fib_info_rcu=
=0A=
=0A=
________________________________________=0A=
From: Herbert Xu <herbert@gondor.apana.org.au>=0A=
Sent: Thursday, April 20, 2017 9:40 PM=0A=
To: Ghalam, Joe=0A=
Cc: davem@davemloft.net; Wichmann, Clifford; netdev@vger.kernel.org=0A=
Subject: Re: macvlan: Fix device ref leak when purging bc_queue=0A=
=0A=
On Thu, Apr 20, 2017 at 04:09:56PM +0000, Joe.Ghalam@dell.com wrote:=0A=
> I agree with this change, but the same purge would be needed for the macv=
lan_dellink() call also.=0A=
=0A=
I don't think that's necessary because as long as the master=0A=
device is still around it will continue to process the broadcast=0A=
queue, thus removing any reference counts held.=0A=
=0A=
It's only when the queue is purged that we run into trouble.=0A=
=0A=
Cheers,=0A=
--=0A=
Email: Herbert Xu <herbert@gondor.apana.org.au>=0A=
Home Page: http://gondor.apana.org.au/~herbert/=0A=
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt=
