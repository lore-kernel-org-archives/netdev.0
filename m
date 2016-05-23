From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: bpf: use-after-free in array_map_alloc
Date: Mon, 23 May 2016 14:07:03 +0200
Message-ID: <5742F267.3000309@suse.cz>
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com> <5742F127.6080000@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Linux-MM layout <linux-mm@kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5742F127.6080000@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2016 02:01 PM, Vlastimil Babka wrote:
>> if I read the report correctly it's not about bpf, but rather points to
>> the issue inside percpu logic.
>> First __alloc_percpu_gfp() is called, then the memory is freed with
>> free_percpu() which triggers async pcpu_balance_work and then
>> pcpu_extend_area_map is hitting use-after-free.
>> I guess bpf percpu array map is stressing this logic the most.
> 
> I've been staring at it for a while (not knowing the code at all) and
> the first thing that struck me is that pcpu_extend_area_map() is done
> outside of pcpu_lock. So what prevents the chunk from being freed during
> the extend?

Erm to be precise, pcpu_lock is unlocked just before calling
pcpu_extend_area_map(), which relocks it after an allocation, and
assumes the chunk still exists at that point. Unless I'm missing
something, that's an unlocked window where chunk can be destroyed by the
workfn, as the report suggests?
