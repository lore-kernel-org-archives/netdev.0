From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v5 3/3] samples/bpf: Add
 test_current_task_under_cgroup test
Date: Fri, 12 Aug 2016 09:10:08 -0700
Message-ID: <20160812161006.GA43887@ast-mbp.thefacebook.com>
References: <20160812155703.GA12893@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, tj@kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34998 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbcHLQKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 12:10:13 -0400
Received: by mail-pf0-f195.google.com with SMTP id h186so1742604pfg.2
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 09:10:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160812155703.GA12893@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 12, 2016 at 08:57:04AM -0700, Sargun Dhillon wrote:
> This test has a BPF program which writes the last known pid to call the
> sync syscall within a given cgroup to a map.
> 
> The user mode program creates its own mount namespace, and mounts the
> cgroupsv2  hierarchy in there, as on all current test systems
> (Ubuntu 16.04, Debian), the cgroupsv2 vfs is unmounted by default.
> Once it does this, it proceeds to test.
> 
> The test checks for positive and negative condition. It ensures that
> when it's part of a given cgroup, its pid is captured in the map,
> and that when it leaves the cgroup, this doesn't happen.
> 
> It populate a cgroups arraymap prior to execution in userspace. This means
> that the program must be run in the same cgroups namespace as the programs
> that are being traced.
> 
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tejun Heo <tj@kernel.org>

I don't think there is much value explicitly adding 'cc:' to commit log.

> +	if (join_cgroup("/mnt/my-cgroup")) {
> +		log_err("Leaving target cgroup");
> +		goto cleanup_cgroup_err;
> +	}
> +
> +	/*
> +	 * The installed helper program catched the sync call, and should
> +	 * write it to the map.
> +	 */
> +
> +	sync();
> +	bpf_lookup_elem(map_fd[1], &idx, &remote_pid);
> +
> +	if (local_pid != remote_pid) {
> +		fprintf(stderr,
> +			"BPF Helper didn't write correct PID to map, but: %d\n",
> +			remote_pid);
> +		goto leave_cgroup_err;
> +	}
> +
> +	/* Verify the negative scenario; leave the cgroup */
> +	if (join_cgroup(CGROUP_MOUNT_PATH))
> +		goto leave_cgroup_err;
> +
> +	remote_pid = 0;
> +	bpf_update_elem(map_fd[1], &idx, &remote_pid, BPF_ANY);
> +
> +	sync();
> +	bpf_lookup_elem(map_fd[1], &idx, &remote_pid);
> +
> +	if (local_pid == remote_pid) {
> +		fprintf(stderr, "BPF cgroup negative test did not work\n");
> +		goto cleanup_cgroup_err;
> +	}
> +
> +	rmdir(CGROUP_PATH);
> +	return 0;

Nice test. Thanks
Acked-by: Alexei Starovoitov <ast@kernel.org>
