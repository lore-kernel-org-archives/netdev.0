From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next rfc 0/2] Allow unpriveledge user to disable
 tuntap queue
Date: Tue, 11 Dec 2012 14:46:16 +0200
Message-ID: <20121211124616.GC15435@redhat.com>
References: <1355223827-57290-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pmoore@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mprivozn@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1355223827-57290-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 11, 2012 at 07:03:45PM +0800, Jason Wang wrote:
> This series is an rfc that tries to solve the issue that the queues of tuntap
> could not be disabled/enabled by unpriveledged user. This is needed for
> unpriveledge userspace such as qemu since guest may change the number of queues
> at any time, qemu needs to configure the tuntap to disable/enable a specific
> queue.
> 
> Instead of introducting new flag/ioctls, this series tries to re-use the current
> TUNSETQUEUE and IFF_ATTACH_QUEUE/IFF_DETACH_QUEUE. After this change,
> IFF_DETACH_QUEUE is used to disable a specific queue instead of detaching all
> its state from tuntap. IFF_ATTACH_QUEUE is used to do: 1) creating new queue to
> a tuntap device, in this situation, previous DAC check is still done. 2)
> re-enable the queue previously disabled by IFF_DETACH_QUEUE, in this situation,
> we can bypass some checking when we do during queue creating (the check need to
> be done here needs discussion.
> 
> Management software (such as libvirt) then can do:
> - TUNSETIFF to creating device and queue 0
> - TUNSETQUEUE to create the rest of queues
> - Passing them to unpriveledge userspace (such as qemu)

Sorry I find this somewhat confusing.
Why doesn't management call TUNSETIFF to create all queues -
seems cleaner, no? Also has the advantage that it works
without selinux changes.

So why don't we simply fix TUNSETQUEUE such that
1. It only works if already attached to device by TUNSETIFF
2. It does not attach/detach, instead simply enables/disables the queue

This way no new flags, just tweak the semantics of the
existing ones. Need to do this before 3.8 is out though
otherwise we'll end up maintaining the old semantics forever.

> Then the unpriveledge userspace can enable and disable a specific queue through
> IFF_ATTACH_QUEUE and IFF_DETACH_QUEUE.
> 
> This is done by introducing a enabled flags were used to notify whether the
> queue is enabled, and tuntap only send/receive packets when it was enabled.
> 
> Please comment, thanks!
> 
> Jason Wang (2):
>   tuntap: forbid calling TUNSETQUEUE for a persistent device with no
>     queues
>   tuntap: allow unpriveledge user to enable and disable queues
> 
>  drivers/net/tun.c |   78 +++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 files changed, 73 insertions(+), 5 deletions(-)
