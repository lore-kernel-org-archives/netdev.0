From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/3] security: bpf: Add eBPF LSM hooks and security field
 to eBPF map
Date: Thu, 31 Aug 2017 19:05:21 -0700
Message-ID: <20170901020520.uifv6b7tvelgxumf@ast-mbp>
References: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
 <20170831205635.80256-3-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        linux-security-module@vger.kernel.org,
        Jeffrey Vander Stoep <jeffv@google.com>,
        netdev@vger.kernel.org, SELinux <Selinux@tycho.nsa.gov>,
        lorenzo@google.com, Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34030 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750955AbdIACFZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 22:05:25 -0400
Content-Disposition: inline
In-Reply-To: <20170831205635.80256-3-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 01:56:34PM -0700, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
> 
> Introduce a pointer into struct bpf_map to hold the security information
> about the map. The actual security struct varies based on the security
> models implemented. Place the LSM hooks before each of the unrestricted
> eBPF operations, the map_update_elem and map_delete_elem operations are
> checked by security_map_modify. The map_lookup_elem and map_get_next_key
> operations are checked by securtiy_map_read.
> 
> Signed-off-by: Chenbo Feng <fengc@google.com>

...

> @@ -410,6 +418,10 @@ static int map_lookup_elem(union bpf_attr *attr)
>  	if (IS_ERR(map))
>  		return PTR_ERR(map);
>  
> +	err = security_map_read(map);
> +	if (err)
> +		return -EACCES;
> +
>  	key = memdup_user(ukey, map->key_size);
>  	if (IS_ERR(key)) {
>  		err = PTR_ERR(key);
> @@ -490,6 +502,10 @@ static int map_update_elem(union bpf_attr *attr)
>  	if (IS_ERR(map))
>  		return PTR_ERR(map);
>  
> +	err = security_map_modify(map);

I don't feel these extra hooks are really thought through.
With such hook you'll disallow map_update for given map. That's it.
The key/values etc won't be used in such security decision.
In such case you don't need such hooks in update/lookup at all.
Only in map_creation and object_get calls where FD can be received.
In other words I suggest to follow standard unix practices:
Do permissions checks in open() and allow read/write() if FD is valid.
Same here. Do permission checks in prog_load/map_create/obj_pin/get
and that will be enough to jail bpf subsystem.
bpf cmds that need to be fast (like lookup and update) should not
have security hooks.
