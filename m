From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/9] bpf: introduce percpu_freelist
Date: Mon, 7 Mar 2016 10:26:38 -0800
Message-ID: <56DDC7DE.4040308@fb.com>
References: <1457315917-1970307-1-git-send-email-ast@fb.com>
 <1457315917-1970307-3-git-send-email-ast@fb.com>
 <56DD5902.3000801@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44516 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752082AbcCGS1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 13:27:19 -0500
In-Reply-To: <56DD5902.3000801@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/16 2:33 AM, Daniel Borkmann wrote:
> On 03/07/2016 02:58 AM, Alexei Starovoitov wrote:
>> Introduce simple percpu_freelist to keep single list of elements
>> spread across per-cpu singly linked lists.
>>
>> /* push element into the list */
>> void pcpu_freelist_push(struct pcpu_freelist *, struct
>> pcpu_freelist_node *);
>>
>> /* pop element from the list */
>> struct pcpu_freelist_node *pcpu_freelist_pop(struct pcpu_freelist *);
>>
>> The object is pushed to the current cpu list.
>> Pop first trying to get the object from the current cpu list,
>> if it's empty goes to the neigbour cpu list.
>>
>> For bpf program usage pattern the collision rate is very low,
>> since programs push and pop the objects typically on the same cpu.
>>
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>
> These bits and their usage in combination with preallocation of objects
> in patch 3/9 look very useful to me!
>
> This code seems generic enough and doesn't contain any BPF specifics,
> other subsystems could potentially utilize it as well, I'd suggest that
> this should better be placed under lib/ so it's exposed/visible for other
> developers too.

I thought about that but the code is bpf usage pattern specific.
It only looks generic. If it's in the lib/ the patches will start
piling in to make it actually generic and adding features that not
only may slow it down, but will risk breaking bpf usage in subtle ways.
It being in kernel/bpf/ is a clear sign that it's for bpf maps only.
When it's in lib/ it's like an invitation to use it for something else
which is the opposite of the trade-offs made here. It's specific to
bpf usage pattern. That's why it performs better than all other
alternatives I've tried.
