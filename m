From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v1 3/5] cgroup: Protect access to task_cls_classid() when
 built as module
Date: Mon, 20 Aug 2012 15:33:59 +0400
Message-ID: <503220A7.2010807@parallels.com>
References: <1345215494-9181-1-git-send-email-wagi@monom.org> <1345215494-9181-4-git-send-email-wagi@monom.org> <20120817182855.GA11607@hmsreliant.think-freely.org> <20120820112938.GA22415@candlejack.bmw-carit.intra>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120820112938.GA22415-rjQKm2AMs/APuY3F5OKgMy7zKzJi9e1+kcYEyfhdaNw@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/20/2012 03:29 PM, Daniel Wagner wrote:
>> This is racy I think.  The read of the static key is atomic with other reads,
>> > but the entire conditional is not atomic.  If two cpus were creating cgroups in
>> > parallel, it would be possible for both to read the static key as being zero
>> > (the second cpu would read the key before the first cpu could increment it).
> D'oh, That is racy.
> 

Take a look at how we solve this particular problem in memcg. By using a
pair of bits meaning "ever active" and "currently active", we can avoid
problems with the static key increments.

Nothing bad can't happen by increasing the static key more than once;
the problem is that you need to somehow take note of that to make sure
you decrement the as many times you incremented when you release it.

Two other important things to keep in mind while dealing with static
branches:

* You can't increase/decrease while holding the cgroup_lock. lockdep may
trigger, because the cgroup_lock holds the cpu_hotplug lock, that the
static branches update path will also take. (due to cpusets). Doing a
logical hotplug will stress this path, and make the problem visible.

Take a look at disarm_sock_keys() (mm/memcontrol.c) to see how we solve
this particular problem.

* If you have code in more than one call site, the update among them is
not atomic. Not sure if this one applies to your case, but it can lead
you to some very unpleasant to debug problems. We use one of those two
bits I mentioned ("currently active") to make sure objects are not
marked before all sites are already patched.

Hope our previous experience with this can help you.
