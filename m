From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 2/4] pktgen: make sure that pktgen_thread_worker has
	been executed
Date: Tue, 20 May 2008 22:43:42 +0400
Message-ID: <1211309022.7496.3.camel@iris.sw.ru>
References: <1211277589-8565-1-git-send-email-den@openvz.org>
	 <1211277589-8565-2-git-send-email-den@openvz.org>
	 <18483.6334.468166.282922@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Ben Greear <greearb@candelatech.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763449AbYETSoY@vger.kernel.org>
In-Reply-To: <18483.6334.468166.282922@robur.slu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-05-20 at 20:30 +0200, Robert Olsson wrote:
> Denis V. Lunev writes:
> 
>  > The problem is that pktgen_thread_worker can not be executed if kthread_stop
>  > has been called too early. Insert a completion on the normal initialization
>  > path to make sure that pktgen_thread_worker will gain the control for sure.
> 
> 
>  Yes how about if we move the wait_for_completion() to pg_cleanup before
>  we remove the threads. And move the complete() last in pktgen_thread_worker. 
>  This completion would sync with both start and stop.
> 
>  Cheers.
> 					--ro

you can't. The idea is to have a checkpoint _before_ khread_stop.
Currently you have a race between


static int kthread(void *_create)
{
   ...
   if (!kthread_should_stop())
       pktgen_thread_worker();
   ...
}

and kthread_stop. If kthread_stop will be called _before_ the control
goes inside pktgen_thread_worker you'll OOPS.

Regards,
	Den
