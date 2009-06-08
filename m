From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 8 Jun 2009 15:39:51 +0900
Message-ID: <20090608153951.dfa4b162.usui@mxm.nes.nec.co.jp>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090601181201.ca1c2832.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	hadi@cyberus.ca, jarkao2@gmail.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:50413 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbZFHHAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:00:05 -0400
In-Reply-To: <20090601181201.ca1c2832.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas

On Mon, 1 Jun 2009 18:12:01 +0900
Minoru Usui <usui@mxm.nes.nec.co.jp> wrote:

> Hi Thomas
> 
> Original mail sent to netdev and containers before.
> (http://www.spinics.net/lists/netdev/msg97745.html)
> 
> I have a question about how to use cls_cgroup.
> 
> On Thu, 21 May 2009 09:22:56 +0900
> Minoru Usui <usui@mxm.nes.nec.co.jp> wrote:
> 
> > Hi
> > 
> > Unfortunately this is only panic report.
> > 
> > I used cgroup net_cls subsystem, then kernel panic occured.
> > I attach panic message and kernel config in this mail's last paragraph.
> > If my operation is wrong, could you tell me how to use net_cls and
> > where the documentation is. 
> > 
> > # But I think panic is very bad even if my operation is wrong.
> 
> The cause of panic will fix soon. (Now I'll make a patch and will test it.)
> 
> I want to know how to use cls_cgroup correctly, so could you tell me how to use it if my operation is wrong. 
> Now, I think I might have to specify 'handle' with tc command line, is this true?
> But when I specified 'handle', I faced oops. X-P

I investigated this problem, and I found a bug in cls_cgroup_change() in cls_cgroup.c.
cls_cgroup_change() expected tca[TCA_OPTIONS] was set from user space properly,
but tc in iproute2-2.6.29-1 (which I used) didn't set it.

I saw the current source code of tc in git, I found the code for cls_cgroup in iproute2/tc/f_cgroup.c.
It set tca[TCA_OPTIONS].

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

# Unfortunately, current source coude of iproute2 couldn't compile, because it occured compile error. X-P
# But this is another issue.

If we always use a newest iproute2 in git when we use cls_cgroup, we don't face this oops probably.
But I think, kernel shouldn't panic regardless of use program's behaviour. 


Signed-off-by: Minoru Usui <usui@mxm.nes.nec.co.jp>

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index cc29b44..2ec0adc 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -167,6 +167,9 @@ static int cls_cgroup_change(struct tcf_proto *tp, unsigned long base,
 	struct tcf_exts e;
 	int err;
 
+	if (!tca[TCA_OPTIONS])
+		return -EINVAL;
+
 	if (head == NULL) {
 		if (!handle)
 			return -EINVAL;


-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
