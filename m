From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v0 4/4] cgroup: net_cls: Rework update socket logic
Date: Wed, 17 Oct 2012 07:02:01 -0700
Message-ID: <507EBA59.9080307@intel.com>
References: <1350479078-29361-1-git-send-email-wagi@monom.org> <1350479078-29361-5-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350479078-29361-5-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/17/2012 6:04 AM, Daniel Wagner wrote:
> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>
> The cgroup logic part of net_cls is very similar as the one in
> net_prio. Let's stream line the net_cls logic with the net_prio one.
>

[...]


>
> +static void cgrp_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
> +{
> +	struct task_struct *p;
> +
> +	cgroup_taskset_for_each(p, cgrp, tset) {
> +		unsigned int fd;
> +		struct fdtable *fdt;
> +		struct files_struct *files;
> +
> +		task_lock(p);
> +		files = p->files;
> +		if (!files) {
> +			task_unlock(p);
> +			continue;
> +		}
> +
> +		spin_lock(&files->file_lock);
> +		fdt = files_fdtable(files);
> +		for (fd = 0; fd < fdt->max_fds; fd++) {
> +			struct file *file;
> +			struct socket *sock;
> +			int err;
> +
> +			file = fcheck_files(files, fd);
> +			if (!file)
> +				continue;
> +
> +			sock = sock_from_file(file, &err);
> +			if (sock)
> +				sock_update_classid(sock->sk, p);
> +		}
> +		spin_unlock(&files->file_lock);

This block should probably use iterate_fd() instead of open coding
this. See the latest net_prio_attach().

.John

> +		task_unlock(p);
> +	}
> +}
> +
