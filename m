From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 2/2] iproute2: add support for invisible qdisc dumping
Date: Mon, 24 Apr 2017 10:43:10 +0200
Message-ID: <20170424084310.GB4126@nanopsycho.orion>
References: <alpine.LSU.2.20.1703081303490.31814@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.20.1703081303490.31814@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Mar 08, 2017 at 01:04:42PM CET, jikos@kernel.org wrote:
>From: Jiri Kosina <jkosina@suse.cz>
>
>Support the new TCA_DUMP_INVISIBLE netlink attribute that allows asking 
>kernel to perform 'full qdisc dump', as for historical reasons some of the 
>default qdiscs are being hidden by the kernel.
>
>The command syntax is being extended by voluntary 'invisible' argument to
>'tc qdisc show'.
>
>Signed-off-by: Jiri Kosina <jkosina@suse.cz>
>---

[...]


>@@ -325,7 +328,25 @@ static int tc_qdisc_list(int argc, char **argv)
> 		filter_ifindex = t.tcm_ifindex;
> 	}
> 
>-	if (rtnl_dump_request(&rth, RTM_GETQDISC, &t, sizeof(t)) < 0) {
>+	if (dump_invisible) {
>+		struct {
>+			struct nlmsghdr n;
>+			struct tcmsg t;
>+			char buf[256];
>+		} req = {
>+			.n.nlmsg_type = RTM_GETQDISC,
>+			.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg)),
>+		};
>+
>+		req.t.tcm_family = AF_UNSPEC;
>+
>+		addattr(&req.n, 256, TCA_DUMP_INVISIBLE);
>+		if (rtnl_dump_request_n(&rth, &req.n) < 0) {

Jirko, you ignore the values that were previously set in "t". I think
that you can change this to do rtnl_dump_request_n always and simplify
the code a bit.


>+			perror("Cannot send dump request");
>+			return 1;
>+		}
>+
>+	} else if (rtnl_dump_request(&rth, RTM_GETQDISC, &t, sizeof(t)) < 0) {
> 		perror("Cannot send dump request");
> 		return 1;
> 	}
>-- 
>Jiri Kosina
>SUSE Labs
>
