From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Mon, 19 Sep 2016 16:28:48 -0700
Message-ID: <20160919162848.2b916955@xeon-e3>
References: <1474236233-28511-1-git-send-email-ncardwell@google.com>
        <1474236233-28511-17-git-send-email-ncardwell@google.com>
        <20160919135734.04ab5172@xeon-e3>
        <CANn89i+MpNPYn=ewi_LioNctNePCuity_UXw5ieU7HFfoZTsGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36672 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751443AbcISX2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 19:28:38 -0400
Received: by mail-pf0-f178.google.com with SMTP id q2so175881pfj.3
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 16:28:38 -0700 (PDT)
In-Reply-To: <CANn89i+MpNPYn=ewi_LioNctNePCuity_UXw5ieU7HFfoZTsGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 14:10:39 -0700
Eric Dumazet <edumazet@google.com> wrote:

> On Mon, Sep 19, 2016 at 1:57 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> 
> > Looks good, but could I suggest a simple optimization.
> > All these parameters are immutable in the version of BBR you are submitting.
> > Why not make the values const? And eliminate the always true long-term bw estimate
> > variable?
> >  
> 
> We could do that.
> 
> We used to have variables (aka module params) while BBR was cooking in
> our kernels ;)
> 
> Are you sure generated code is indeed 'optimized' ?


It generates some slightly smaller code.
 	if (bbr->lt_rtt_cnt < bbr_lt_intvl_min_rtts)
- 3e7:	0f b6 c0             	movzbl %al,%eax
- 3ea:	83 f8 03             	cmp    $0x3,%eax
- 3ed:	0f 86 d4 00 00 00    	jbe    4c7 <bbr_lt_bw_sampling.isra.6+0x157>
+ 3e7:	3c 03                	cmp    $0x3,%al
+ 3e9:	0f 86 d1 00 00 00    	jbe    4c0 <bbr_lt_bw_sampling.isra.6+0x150>

And different code for abs
 		/* Is new bw close to the lt_bw from the previous interval? */
 		diff = abs(bw - bbr->lt_bw);
- 47a:	44 89 e2             	mov    %r12d,%edx
- 47d:	29 c2                	sub    %eax,%edx
- 47f:	89 d1                	mov    %edx,%ecx
- 481:	89 d3                	mov    %edx,%ebx
+ 475:	44 89 e3             	mov    %r12d,%ebx
+ 478:	29 c3                	sub    %eax,%ebx
+ 47a:	89 da                	mov    %ebx,%edx
+ 47c:	c1 fa 1f             	sar    $0x1f,%edx
+ 47f:	31 d3                	xor    %edx,%ebx
+ 481:	29 d3                	sub    %edx,%ebx

The biggest change is getting rid of the always true conditional.

-	u32 diff;
-
-	if (bbr->lt_bw &&  /* do we have bw from a previous interval? */
-	    bbr_lt_bw_estimator) {  /* using long-term bw estimator enabled? */
-		/* Is new bw close to the lt_bw from the previous interval? */
-		diff = abs(bw - bbr->lt_bw);
- 485:	c1 f9 1f             	sar    $0x1f,%ecx
-		if ((diff * BBR_UNIT <= bbr_lt_conv_thresh * bbr->lt_bw) ||
- 488:	c1 e2 05             	shl    $0x5,%edx
-	u32 diff;
-
-	if (bbr->lt_bw &&  /* do we have bw from a previous interval? */
-	    bbr_lt_bw_estimator) {  /* using long-term bw estimator enabled? */
-		/* Is new bw close to the lt_bw from the previous interval? */
-		diff = abs(bw - bbr->lt_bw);
- 48b:	31 cb                	xor    %ecx,%ebx
- 48d:	29 cb                	sub    %ecx,%ebx
-		if ((diff * BBR_UNIT <= bbr_lt_conv_thresh * bbr->lt_bw) ||
- 48f:	89 d9                	mov    %ebx,%ecx
- 491:	c1 e1 08             	shl    $0x8,%ecx
- 494:	39 d1                	cmp    %edx,%ecx
- 496:	0f 87 6e 01 00 00    	ja     60a <bbr_lt_bw_sampling.isra.6+0x29a>
+ 485:	89 d9                	mov    %ebx,%ecx
+ 487:	c1 e2 05             	shl    $0x5,%edx
+ 48a:	c1 e1 08             	shl    $0x8,%ecx
+ 48d:	39 d1                	cmp    %edx,%ecx
+ 48f:	0f 87 6e 01 00 00    	ja     603 <bbr_lt_bw_sampling.isra.6+0x293>


Overall, it really makes little difference. Actual file sizes come out the same.
The idea is more to document what is variable
and what is immutable in the algorithm.
