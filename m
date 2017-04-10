From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] bpf: remove struct bpf_prog_type_list
Date: Sun, 09 Apr 2017 18:22:36 -0700 (PDT)
Message-ID: <20170409.182236.865920818973965236.davem@davemloft.net>
References: <20170407190008.32632-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750882AbdDJBWi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 21:22:38 -0400
In-Reply-To: <20170407190008.32632-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri,  7 Apr 2017 21:00:07 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> There's no need to have struct bpf_prog_type_list since
> it just contains a list_head, the type, and the ops
> pointer. Since the types are densely packed and not
> actually dynamically registered, it's much easier and
> smaller to have an array of type->ops pointer. Also
> initialize this array statically to remove code needed
> to initialize it.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

If you just don't want to list things multiple times how about:

linux/bpf_verifiers.h:
BPF_VERIFIER(BPF_PROG_TYPE_SOCKET_FILTER, sk_filter_prog_ops)
BPF_VERIFIER(BPF_PROG_TYPE_SCHED_CLS, tc_cls_prog_ops)
 ...

Then in bpf.h:

#define BPF_VERIFIER(TYPE_VAL, SYM) extern const struct bpf_verifier_ops SYM;
#include <linux/bpf_verifiers.h"

and in kernel/bpf/syscall.c:

#define BPF_VERIFIER(TYPE_VAL, SYM) [TYPE_VAL] = &SYM,
#include <linux/bpf_verifiers.h"

or something like that.

Maybe there is some even more straightforward way to do this without
using sections or anything like that, which we can't see right now :)
