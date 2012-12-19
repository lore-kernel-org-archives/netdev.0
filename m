From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH v3 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Wed, 19 Dec 2012 13:46:25 +0800
Message-ID: <50D154B1.4010909@redhat.com>
References: <20121218225001.16104.34454.stgit@localhost> <20121218225351.16104.48513.stgit@localhost> <20121218230808.GC1135@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <pmoore@redhat.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121218230808.GC1135@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/19/2012 07:08 AM, Michael S. Tsirkin wrote:
> On Tue, Dec 18, 2012 at 05:53:52PM -0500, Paul Moore wrote:
>> This patch corrects some problems with LSM/SELinux that were introduced
>> with the multiqueue patchset.  The problem stems from the fact that the
>> multiqueue work changed the relationship between the tun device and its
>> associated socket; before the socket persisted for the life of the
>> device, however after the multiqueue changes the socket only persisted
>> for the life of the userspace connection (fd open).  For non-persistent
>> devices this is not an issue, but for persistent devices this can cause
>> the tun device to lose its SELinux label.
>>
>> We correct this problem by adding an opaque LSM security blob to the
>> tun device struct which allows us to have the LSM security state, e.g.
>> SELinux labeling information, persist for the lifetime of the tun
>> device.  In the process we tweak the LSM hooks to work with this new
>> approach to TUN device/socket labeling and introduce a new LSM hook,
>> security_tun_dev_attach_queue(), to approve requests to attach to a
>> TUN queue via TUNSETQUEUE.
>>
>> The SELinux code has been adjusted to match the new LSM hooks, the
>> other LSMs do not make use of the LSM TUN controls.  This patch makes
>> use of the recently added "tun_socket:attach_queue" permission to
>> restrict access to the TUNSETQUEUE operation.  On older SELinux
>> policies which do not define the "tun_socket:attach_queue" permission
>> the access control decision for TUNSETQUEUE will be handled according
>> to the SELinux policy's unknown permission setting.
>>
>> Signed-off-by: Paul Moore <pmoore@redhat.com>
>
> Looks good to me. A comment not directly related to this patch, below.

Good to me too, will do some test on this.
>
>> ---
>>  drivers/net/tun.c                 |   27 +++++++++++++----
>>  include/linux/security.h          |   59 +++++++++++++++++++++++++++++--------
>>  security/capability.c             |   24 +++++++++++++--
>>  security/security.c               |   28 ++++++++++++++----
>>  security/selinux/hooks.c          |   50 ++++++++++++++++++++++++-------
>>  security/selinux/include/objsec.h |    4 +++
>>  6 files changed, 154 insertions(+), 38 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 504f7f1..4b7754c 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -186,6 +186,7 @@ struct tun_struct {
>>  	unsigned long ageing_time;
>>  	unsigned int numdisabled;
>>  	struct list_head disabled;
>> +	void *security;
>>  };
>>  
[...]
>>  
>> @@ -1805,12 +1813,18 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
>>  
>>  	if (ifr->ifr_flags & IFF_ATTACH_QUEUE) {
>>  		tun = tfile->detached;
>> -		if (!tun)
>> +		if (!tun) {
>>  			ret = -EINVAL;
>> -		else if (tun_not_capable(tun))
>> +			goto unlock;
>> +		}
>> +		if (tun_not_capable(tun)) {
> By the way I don't think we need to limit set_queue
> by tun_not_capable. It simply makes a queue active/inactive
> which seems harmless. Jason?

Maybe we should keep this, when a tun has a owner it would not expected
any other user except the one has CAP_NET_ADMIN to active or de-active a
queue.
>
>>  			ret = -EPERM;
>> -		else
[...]
