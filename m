From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: sock memory leak
Date: Fri, 15 Jan 2016 16:46:20 -0200
Message-ID: <20160115184620.GE6074@mrl.redhat.com>
References: <CACT4Y+bf9h=vVSb82Jdv2GeV1MQPg15LW_AcV2BOw-XbMfNetw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+bf9h=vVSb82Jdv2GeV1MQPg15LW_AcV2BOw-XbMfNetw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2015 at 09:42:27PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> The following program leads to a leak of two sock objects:
...
> 
> On commit 8513342170278468bac126640a5d2d12ffbff106 (Dec 28).

I'm afraid I cannot reproduce this one?
I enabled dynprintk at sctp_destroy_sock and it does print twice when I
run this test app.
Also added debugs to check association lifetime, and then it was
destroyed. Same for endpoint. 

Checking with trace-cmd, both calls to sctp_close() resulted in
sctp_destroy_sock() being called.

As for sock_hold/put, they are matched too. 

Ideas? Log is below for double checking

[ 1112.558217] sctp_endpoint_init(ffff88000015d400) sock_hold sk:ffff8800336da000
[ 1112.558539] sctp_endpoint_hold(ffff88000015d400)
[ 1112.558544] sctp_association_init(ffff8800b2db9000) sock_hold sk:ffff8800336da000
[ 1112.558878] sctp_association_hold(ffff8800b2db9000)
[ 1112.558957] sctp_association_hold(ffff8800b2db9000)
[ 1112.559062] sctp_association_hold(ffff8800b2db9000)
[ 1112.559079] sctp_association_hold(ffff8800b2db9000)
[ 1112.658745] sctp_endpoint_init(ffff88000015e200) sock_hold sk:ffff8800336dc800
[ 1112.658815] sctp_endpoint_put(ffff88000015d400)
[ 1112.658819] sctp_assoc_migrate(ffff8800b2db9000) sock_put sk:ffff8800336da000 oldsk:ffff8800336da000
[ 1112.658822] sctp_endpoint_hold(ffff88000015e200)
[ 1112.658824] sctp_assoc_migrate(ffff8800b2db9000) sock_hold sk:ffff8800336dc800
[ 1112.659627] sctp_association_put(ffff8800b2db9000)
[ 1112.659673] sctp_association_free(ffff8800b2db9000)
[ 1112.659691] sctp_association_put(ffff8800b2db9000)
[ 1112.659735] sctp_transport_put(ffff8800b3426000)
[ 1112.659737] sctp_transport_destroy(ffff8800b3426000)
[ 1112.659741] sctp_association_put(ffff8800b2db9000)
[ 1112.659745] sctp_association_put(ffff8800b2db9000)
[ 1112.659757] sctp_association_put(ffff8800b2db9000)
[ 1112.659759] sctp_association_destroy(ffff8800b2db9000)
[ 1112.659761] sctp_endpoint_put(ffff88000015e200)
[ 1112.659773] sctp_association_destroy(ffff8800b2db9000) sock_put sk:ffff8800336dc800
[ 1112.659814] sctp_close sock_hold sk:ffff8800336dc800
[ 1112.659818] sctp: sctp_destroy_sock: sk:ffff8800336dc800
[ 1112.659823] sctp_endpoint_put(ffff88000015e200)
[ 1112.659825] sctp_endpoint_destroy(ffff88000015e200)
[ 1112.659841] sctp_endpoint_destroy(ffff88000015e200) sock_put sk:ffff8800336dc800
[ 1112.659852] sctp_close sock_put sk:ffff8800336dc800
[ 1112.662437] sctp_close sock_hold sk:ffff8800336da000
[ 1112.662443] sctp: sctp_destroy_sock: sk:ffff8800336da000
[ 1112.662448] sctp_endpoint_put(ffff88000015d400)
[ 1112.662450] sctp_endpoint_destroy(ffff88000015d400)
[ 1112.662466] sctp_endpoint_destroy(ffff88000015d400) sock_put sk:ffff8800336da000
[ 1112.662476] sctp_close sock_put sk:ffff8800336da000
[ 1112.677226] sctp_transport_destroy_rcu(ffff8800b3426000)
