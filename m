From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 4/4] vhost: Add cgroup-aware creation of worker
 threads
Date: Tue, 28 Jul 2015 00:12:16 +0300
Message-ID: <20150728000758-mutt-send-email-mst@redhat.com>
References: <1436760455-5686-1-git-send-email-bsd@redhat.com>
 <1436760455-5686-5-git-send-email-bsd@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eyal Moscovici <EYALMO@il.ibm.com>,
	Razya Ladelsky <RAZYA@il.ibm.com>, cgroups@vger.kernel.org,
	jasowang@redhat.com, Tejun Heo <tj@kernel.org>
To: Bandan Das <bsd@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436760455-5686-5-git-send-email-bsd@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 13, 2015 at 12:07:35AM -0400, Bandan Das wrote:
> With the help of the cgroup function to compare groups introduced
> in the previous patch, this changes worker creation policy.
> If the new device belongs to different cgroups than any of the
> devices we are currently serving, we end up creating a new worker
> thread even if we haven't reached the devs_per_worker threshold
> 
> Signed-off-by: Bandan Das <bsd@redhat.com>

Would it make sense to integrate this in the work-queue mechanism somehow?
Just a thought - correctly accounting kernel's work
on behalf of specific userspace groups might have value generally.
Or is the usecase too special?
Cc Tejun for comments.

> ---
>  drivers/vhost/vhost.c | 47 +++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 39 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 6a5d4c0..dc0fa37 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -261,12 +261,6 @@ static int vhost_worker(void *data)
>  				use_mm(dev->mm);
>  			}
>  
> -			/* TODO: Consider a more elegant solution */
> -			if (worker->owner != dev->owner) {
> -				/* Should check for return value */
> -				cgroup_attach_task_all(dev->owner, current);
> -				worker->owner = dev->owner;
> -			}
>  			work->fn(work);
>  			if (need_resched())
>  				schedule();
> @@ -278,6 +272,36 @@ static int vhost_worker(void *data)
>  	return 0;
>  }
>  
> +struct vhost_attach_cgroups_struct {
> +	struct vhost_work work;
> +	struct task_struct *owner;
> +	int ret;
> +};
> +
> +static void vhost_attach_cgroups_work(struct vhost_work *work)
> +{
> +	struct vhost_attach_cgroups_struct *s;
> +
> +	s = container_of(work, struct vhost_attach_cgroups_struct, work);
> +	s->ret = cgroup_attach_task_all(s->owner, current);
> +}
> +
> +static void vhost_attach_cgroups(struct vhost_dev *dev,
> +				struct vhost_worker *worker)
> +{
> +	struct vhost_attach_cgroups_struct attach;
> +
> +	attach.owner = dev->owner;
> +	vhost_work_init(dev, &attach.work, vhost_attach_cgroups_work);
> +	vhost_work_queue(worker, &attach.work);
> +	vhost_work_flush(worker, &attach.work);
> +
> +	if (!attach.ret)
> +		worker->owner = dev->owner;
> +
> +	dev->err = attach.ret;
> +}
> +
>  static void vhost_create_worker(struct vhost_dev *dev)
>  {
>  	struct vhost_worker *worker;
> @@ -300,8 +324,14 @@ static void vhost_create_worker(struct vhost_dev *dev)
>  
>  	spin_lock_init(&worker->work_lock);
>  	INIT_LIST_HEAD(&worker->work_list);
> +
> +	/* attach to the cgroups of the process that created us */
> +	vhost_attach_cgroups(dev, worker);
> +	if (dev->err)
> +		goto therror;
> +	worker->owner = dev->owner;
> +
>  	list_add(&worker->node, &pool->workers);
> -	worker->owner = NULL;
>  	worker->num_devices++;
>  	total_vhost_workers++;
>  	dev->worker = worker;
> @@ -320,7 +350,8 @@ static int vhost_dev_assign_worker(struct vhost_dev *dev)
>  
>  	mutex_lock(&vhost_pool->pool_lock);
>  	list_for_each_entry(worker, &vhost_pool->workers, node) {
> -		if (worker->num_devices < devs_per_worker) {
> +		if (worker->num_devices < devs_per_worker &&
> +		    (!cgroup_match_groups(dev->owner, worker->owner))) {
>  			dev->worker = worker;
>  			dev->worker_assigned = true;
>  			worker->num_devices++;
> -- 
> 2.4.3
