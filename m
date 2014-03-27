From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] openvswitch: fix a possible deadlock and lockdep warning
Date: Thu, 27 Mar 2014 10:19:23 -0700
Message-ID: <CALnjE+q41G9KKf_EhTdDvZtX_Xao_WG+KhRZ2fKe0JF8sqjZxw@mail.gmail.com>
References: <1395929134-4487-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, openvswitch <dev@openvswitch.org>
To: Flavio Leitner <fbl@redhat.com>, Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:36471 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755175AbaC0RTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 13:19:25 -0400
Received: by mail-ve0-f172.google.com with SMTP id jx11so4501689veb.3
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 10:19:23 -0700 (PDT)
In-Reply-To: <1395929134-4487-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2014 at 7:05 AM, Flavio Leitner <fbl@redhat.com> wrote:
> There are two problematic situations.
>
> A deadlock can happen when is_percpu is false because it can get
> interrupted while holding the spinlock. Then it executes
> ovs_flow_stats_update() in softirq context which tries to get
> the same lock.
>
> The second sitation is that when is_percpu is true, the code
> correctly disables BH but only for the local CPU, so the
> following can happen when locking the remote CPU without
> disabling BH:
>
>        CPU#0                            CPU#1
>   ovs_flow_stats_get()
>    stats_read()
>  +->spin_lock remote CPU#1        ovs_flow_stats_get()
>  |  <interrupted>                  stats_read()
>  |  ...                       +-->  spin_lock remote CPU#0
>  |                            |     <interrupted>
>  |  ovs_flow_stats_update()   |     ...
>  |   spin_lock local CPU#0 <--+     ovs_flow_stats_update()
>  +---------------------------------- spin_lock local CPU#1
>
> This patch disables BH for both cases fixing the deadlocks.

This bug is already fixed in OVS.

Jesse,
Can you send the fix upstream or you waiting for other patches?
