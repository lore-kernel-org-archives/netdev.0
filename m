From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next V4 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Thu, 5 Oct 2017 11:01:48 -0700
Message-ID: <b34454a8-1864-d6bc-644b-c2567ab738d7@gmail.com>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>
 <150711862505.9499.15042356194495111353.stgit@firesoul>
 <20171004190201.5no5mrmkko43cvv2@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33573 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751366AbdJESCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 14:02:06 -0400
Received: by mail-pf0-f195.google.com with SMTP id m28so14934836pfi.0
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 11:02:06 -0700 (PDT)
In-Reply-To: <20171004190201.5no5mrmkko43cvv2@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2017 12:02 PM, Alexei Starovoitov wrote:
> On Wed, Oct 04, 2017 at 02:03:45PM +0200, Jesper Dangaard Brouer wrote:
>> The 'cpumap' is primary used as a backend map for XDP BPF helper
>> call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
>>
>> This patch implement the main part of the map.  It is not connected to
>> the XDP redirect system yet, and no SKB allocation are done yet.
>>
>> The main concern in this patch is to ensure the datapath can run
>> without any locking.  This adds complexity to the setup and tear-down
>> procedure, which assumptions are extra carefully documented in the
>> code comments.
>>
>> V2:
>>  - make sure array isn't larger than NR_CPUS
>>  - make sure CPUs added is a valid possible CPU
>>
>> V3: fix nitpicks from Jakub Kicinski <kubakici@wp.pl>
>>
>> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ...
>> +static struct bpf_map *cpu_map_alloc(union bpf_attr *attr)
>> +{
>> +	struct bpf_cpu_map *cmap;
>> +	u64 cost;
>> +	int err;
>> +
>> +	/* check sanity of attributes */
>> +	if (attr->max_entries == 0 || attr->key_size != 4 ||
>> +	    attr->value_size != 4 || attr->map_flags & ~BPF_F_NUMA_NODE)
>> +		return ERR_PTR(-EINVAL);
>> +
>> +	cmap = kzalloc(sizeof(*cmap), GFP_USER);
>> +	if (!cmap)
>> +		return ERR_PTR(-ENOMEM);
> 
> just noticed that there is nothing here nor in DEVMAP/SOCKMAP
> that prevents unpriv user to create them.
> I'm not sure it was intentional for DEVMAP/SOCKMAP.
> For CPUMAP I'd suggest to restrict it to root, since it
> suppose to operate with XDP only which is root anyway.
> Note, lpm and lru maps are cap_sys_admin only already.
> 

For DEVMAP I think the same argument applies. DEVMAP is supposed
to operate with XDP only which is CAP_NET_ADMIN restricted so
we should restrict DEVMAP as well.

In the SOCKMAP case although the map can be created programs
can not be attached. So I'll restrict it to CAP_NET_ADMIN as well
until someone has a clear use case for allowing it. I don't have
a use case for non CAP_NET_ADMIN usage and its easier to relax
restrictions later than add them.

I have a couple fixes for sockmap under test so I'll add these
patches as well. Should have the set ready shortly, in a few days.

Thanks,
John
