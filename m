From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [net-next:master 332/339] kernel//bpf/syscall.c:1404:23:
 warning: cast to pointer from integer of different size
Date: Fri, 29 Sep 2017 10:04:45 -0700
Message-ID: <20170929170445.ovysyojyqdtu7r3d@kafai-mbp.dhcp.thefacebook.com>
References: <201709291413.dQfHazqk%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <kbuild-all@01.org>, <netdev@vger.kernel.org>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41548 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751975AbdI2REu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 13:04:50 -0400
Content-Disposition: inline
In-Reply-To: <201709291413.dQfHazqk%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 06:54:16AM +0000, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   fa8fefaa678ea390b873195d19c09930da84a4bb
> commit: cb4d2b3f03d8eed90be3a194e5b54b734ec4bbe9 [332/339] bpf: Add name, load_time, uid and map_ids to bpf_prog_info
> config: blackfin-allmodconfig (attached as .config)
> compiler: bfin-uclinux-gcc (GCC) 6.2.0
> reproduce:
>         wget https://urldefense.proofpoint.com/v2/url?u=https-3A__raw.githubusercontent.com_intel_lkp-2Dtests_master_sbin_make.cross&d=DwIBAg&c=5VD0RTtNlTh3ycd41b3MUw&r=VQnoQ7LvghIj0gVEaiQSUw&m=wnwNExnkCiXwLrdN-Pplo3kMRjWoCTfAkAa3ItKKNk0&s=3umQPjRqRXooDy9sh8Dfoq9OPgU5QdIBJHs2GN4G4CE&e=  -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout cb4d2b3f03d8eed90be3a194e5b54b734ec4bbe9
>         # save the attached .config to linux build tree
>         make.cross ARCH=blackfin
I will post a patch once I confirm the fix with this ARCH or any 32bits arch.

> 
> All warnings (new ones prefixed by >>):
> 
>    kernel//bpf/syscall.c: In function 'bpf_prog_get_info_by_fd':
> >> kernel//bpf/syscall.c:1404:23: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
>       u32 *user_map_ids = (u32 *)info.map_ids;
>                           ^
> 
> vim +1404 kernel//bpf/syscall.c
> 
>   1371	
>   1372	static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
>   1373					   const union bpf_attr *attr,
>   1374					   union bpf_attr __user *uattr)
>   1375	{
>   1376		struct bpf_prog_info __user *uinfo = u64_to_user_ptr(attr->info.info);
>   1377		struct bpf_prog_info info = {};
>   1378		u32 info_len = attr->info.info_len;
>   1379		char __user *uinsns;
>   1380		u32 ulen;
>   1381		int err;
>   1382	
>   1383		err = check_uarg_tail_zero(uinfo, sizeof(info), info_len);
>   1384		if (err)
>   1385			return err;
>   1386		info_len = min_t(u32, sizeof(info), info_len);
>   1387	
>   1388		if (copy_from_user(&info, uinfo, info_len))
>   1389			return -EFAULT;
>   1390	
>   1391		info.type = prog->type;
>   1392		info.id = prog->aux->id;
>   1393		info.load_time = prog->aux->load_time;
>   1394		info.created_by_uid = from_kuid_munged(current_user_ns(),
>   1395						       prog->aux->user->uid);
>   1396	
>   1397		memcpy(info.tag, prog->tag, sizeof(prog->tag));
>   1398		memcpy(info.name, prog->aux->name, sizeof(prog->aux->name));
>   1399	
>   1400		ulen = info.nr_map_ids;
>   1401		info.nr_map_ids = prog->aux->used_map_cnt;
>   1402		ulen = min_t(u32, info.nr_map_ids, ulen);
>   1403		if (ulen) {
> > 1404			u32 *user_map_ids = (u32 *)info.map_ids;
>   1405			u32 i;
>   1406	
>   1407			for (i = 0; i < ulen; i++)
>   1408				if (put_user(prog->aux->used_maps[i]->id,
>   1409					     &user_map_ids[i]))
>   1410					return -EFAULT;
>   1411		}
>   1412	
>   1413		if (!capable(CAP_SYS_ADMIN)) {
>   1414			info.jited_prog_len = 0;
>   1415			info.xlated_prog_len = 0;
>   1416			goto done;
>   1417		}
>   1418	
>   1419		ulen = info.jited_prog_len;
>   1420		info.jited_prog_len = prog->jited_len;
>   1421		if (info.jited_prog_len && ulen) {
>   1422			uinsns = u64_to_user_ptr(info.jited_prog_insns);
>   1423			ulen = min_t(u32, info.jited_prog_len, ulen);
>   1424			if (copy_to_user(uinsns, prog->bpf_func, ulen))
>   1425				return -EFAULT;
>   1426		}
>   1427	
>   1428		ulen = info.xlated_prog_len;
>   1429		info.xlated_prog_len = bpf_prog_insn_size(prog);
>   1430		if (info.xlated_prog_len && ulen) {
>   1431			uinsns = u64_to_user_ptr(info.xlated_prog_insns);
>   1432			ulen = min_t(u32, info.xlated_prog_len, ulen);
>   1433			if (copy_to_user(uinsns, prog->insnsi, ulen))
>   1434				return -EFAULT;
>   1435		}
>   1436	
>   1437	done:
>   1438		if (copy_to_user(uinfo, &info, info_len) ||
>   1439		    put_user(info_len, &uattr->info.info_len))
>   1440			return -EFAULT;
>   1441	
>   1442		return 0;
>   1443	}
>   1444	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://urldefense.proofpoint.com/v2/url?u=https-3A__lists.01.org_pipermail_kbuild-2Dall&d=DwIBAg&c=5VD0RTtNlTh3ycd41b3MUw&r=VQnoQ7LvghIj0gVEaiQSUw&m=wnwNExnkCiXwLrdN-Pplo3kMRjWoCTfAkAa3ItKKNk0&s=ZFvkeCNRid_UAZDXdnXHDIMKipbdUgg6ltkBeaVlt1Q&e=                    Intel Corporation
