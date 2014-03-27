From: Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net v2] openvswitch: fix a possible deadlock
 and lockdep warning
Date: Thu, 27 Mar 2014 14:44:34 -0300
Message-ID: <20140327174434.GD2478@t520.home>
References: <1395929134-4487-1-git-send-email-fbl@redhat.com>
 <CALnjE+q41G9KKf_EhTdDvZtX_Xao_WG+KhRZ2fKe0JF8sqjZxw@mail.gmail.com>
 <20140327173344.GK18707@t520.home>
 <CAEP_g=--TMq8s4JdSTcybXgGM6o8mqrWh1NWGFt2Jy4QQuXjmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: openvswitch <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEP_g=--TMq8s4JdSTcybXgGM6o8mqrWh1NWGFt2Jy4QQuXjmA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2014 at 10:37:32AM -0700, Jesse Gross wrote:
> On Thu, Mar 27, 2014 at 10:33 AM, Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> > On Thu, Mar 27, 2014 at 10:19:23AM -0700, Pravin Shelar wrote:
> >> On Thu, Mar 27, 2014 at 7:05 AM, Flavio Leitner <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> > There are two problematic situations.
> >> >
> >> > A deadlock can happen when is_percpu is false because it can get
> >> > interrupted while holding the spinlock. Then it executes
> >> > ovs_flow_stats_update() in softirq context which tries to get
> >> > the same lock.
> >> >
> >> > The second sitation is that when is_percpu is true, the code
> >> > correctly disables BH but only for the local CPU, so the
> >> > following can happen when locking the remote CPU without
> >> > disabling BH:
> >> >
> >> >        CPU#0                            CPU#1
> >> >   ovs_flow_stats_get()
> >> >    stats_read()
> >> >  +->spin_lock remote CPU#1        ovs_flow_stats_get()
> >> >  |  <interrupted>                  stats_read()
> >> >  |  ...                       +-->  spin_lock remote CPU#0
> >> >  |                            |     <interrupted>
> >> >  |  ovs_flow_stats_update()   |     ...
> >> >  |   spin_lock local CPU#0 <--+     ovs_flow_stats_update()
> >> >  +---------------------------------- spin_lock local CPU#1
> >> >
> >> > This patch disables BH for both cases fixing the deadlocks.
> >>
> >> This bug is already fixed in OVS.
> >
> > Could you point me to the commit? I am not finding anything
> > recent.
> 
> This is the commit:
> 
> commit 9d73c9cac76ba557fdac4a89c1b7eafe132b85a3
> Author: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Date:   Tue Dec 17 15:43:30 2013 -0800
> 
>     datapath: Fix deadlock during stats update.
> 
> I thought that I had sent it in the most recent batch of changes for
> net but it looks like I missed it.

That commit is incomplete. Look at the scenario #2 which I explain
why it is needed to disable bh for all cpus and not just local ones.

fbl
