From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 2/2] samples/bpf: add a test for bpf_override_return
Date: Wed, 1 Nov 2017 10:23:36 -0700
Message-ID: <1d75b0ed-4a0d-cdfa-5f74-1401f1b99ae8@fb.com>
References: <1509555643-2899-1-git-send-email-josef@toxicpanda.com>
 <1509555643-2899-3-git-send-email-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>
To: Josef Bacik <josef@toxicpanda.com>, <rostedt@goodmis.org>,
        <mingo@redhat.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <ast@kernel.org>, <kernel-team@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509555643-2899-3-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/1/17 10:00 AM, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
>
> This adds a basic test for bpf_override_return to verify it works.  We
> override the main function for mounting a btrfs fs so it'll return
> -ENOMEM and then make sure that trying to mount a btrfs fs will fail.
>
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>

> +++ b/samples/bpf/test_override_return.sh
> @@ -0,0 +1,15 @@
> +#!/bin/bash
> +
> +rm -f testfile.img
> +dd if=/dev/zero of=testfile.img bs=1M seek=1000 count=1
> +DEVICE=$(losetup --show -f testfile.img)
> +mkfs.btrfs -f $DEVICE
> +mkdir tmpmnt
> +./tracex7 $DEVICE
> +if [ $? -eq 0 ]
> +then
> +	echo "SUCCESS!"
> +else
> +	echo "FAILED!"
> +fi
> +losetup -d $DEVICE
> diff --git a/samples/bpf/tracex7_kern.c b/samples/bpf/tracex7_kern.c
> new file mode 100644
> index 000000000000..1ab308a43e0f
> --- /dev/null
> +++ b/samples/bpf/tracex7_kern.c
> @@ -0,0 +1,16 @@
> +#include <uapi/linux/ptrace.h>
> +#include <uapi/linux/bpf.h>
> +#include <linux/version.h>
> +#include "bpf_helpers.h"
> +
> +SEC("kprobe/open_ctree")
> +int bpf_prog1(struct pt_regs *ctx)
> +{
> +	unsigned long rc = -12;
> +
> +	bpf_override_return(ctx, rc);
> +	return 0;
> +}

great stuff. I wonder in how many kernel test frameworks
it will appear in the near future.
We can even stress test bpf with bpf.
