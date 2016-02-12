From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Fri, 12 Feb 2016 08:45:43 -0600
Message-ID: <20160212144543.GA29004@treble.redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <56BDB5A8.9030006@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Borislav Petkov <bp@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Chris Wright <chrisw@sous
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56BDB5A8.9030006@suse.cz>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 11:36:24AM +0100, Jiri Slaby wrote:
> On 01/21/2016, 11:49 PM, Josh Poimboeuf wrote:
> > This is v16 of the compile-time stack metadata validation patch set,
> > along with proposed fixes for most of the warnings it found.  It's based
> > on the tip/master branch.
> 
> Hi,
> 
> with this config:
> https://github.com/openSUSE/kernel-source/blob/master/config/x86_64/vanilla
> 
> I am seeing a lot of functions in C which do not have frame pointer setup/cleanup:

Hi Jiri,

Thanks for testing.

> stacktool: drivers/scsi/hpsa.o: hpsa_scsi_do_simple_cmd.constprop.106()+0x79: call without frame pointer save/setup

This seems like a real frame pointer bug caused by the following line in
arch/x86/include/asm/preempt.h:

  # define __preempt_schedule() asm ("call ___preempt_schedule")

The asm statement doesn't have the stack pointer as an output operand,
so gcc doesn't skips the frame pointer setup before calling.

However, I suspect the "bug" is intentional for optimization purposes.

> stacktool: drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.o: cfs_cdebug_show.part.5.constprop.35()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.o: cfs_cdebug_show.part.5.constprop.35()+0x8: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.o: cfs_cdebug_show.part.5.constprop.35()+0x9: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lnet/klnds/socklnd/socklnd.o: ksocknal_connsock_decref()+0x0: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lnet/klnds/socklnd/socklnd.o: ksocknal_connsock_decref()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lnet/klnds/socklnd/socklnd.o: ksocknal_connsock_decref()+0x1: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lnet/klnds/socklnd/socklnd.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lnet/lnet/lib-move.o: cfs_cdebug_show.part.1.constprop.16()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lnet/lnet/lib-move.o: cfs_cdebug_show.part.1.constprop.16()+0x8: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lnet/lnet/lib-move.o: cfs_cdebug_show.part.1.constprop.16()+0x9: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lnet/lnet/lib-move.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lnet/lnet/lo.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lnet/lnet/nidstrings.o: cfs_print_nidlist()+0x220: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lnet/lnet/peer.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lnet/lnet/router.o: cfs_cdebug_show.part.0.constprop.16()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lnet/lnet/router.o: cfs_cdebug_show.part.0.constprop.16()+0x8: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lnet/lnet/router.o: cfs_cdebug_show.part.0.constprop.16()+0x9: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lnet/lnet/router.o: lnet_find_net_locked()+0x8a: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lnet/lnet/router.o: lnet_find_net_locked()+0x8a: return without frame pointer restore
> stacktool: drivers/staging/lustre/lustre/fid/fid_request.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/fld/lproc_fld.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/libcfs/libcfs_lock.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/libcfs/libcfs_mem.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/llite/dir.o: obd_unpackmd()+0x0: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/llite/dir.o: obd_unpackmd()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/llite/dir.o: obd_unpackmd()+0x4: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/llite/file.o: md_intent_lock.part.28()+0x0: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/llite/file.o: md_intent_lock.part.28()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/llite/file.o: md_intent_lock.part.28()+0x24: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/llite/../lclient/glimpse.o: cl_io_get()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/llite/../lclient/glimpse.o: cl_io_get()+0x1a: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/llite/../lclient/glimpse.o: cl_io_get()+0x1b: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/llite/../lclient/glimpse.o: cl_io_get()+0x19: return without frame pointer restore
> stacktool: drivers/staging/lustre/lustre/llite/../lclient/lcommon_misc.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/llite/llite_mmap.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/llite/lproc_llite.o: checksum_pages_store()+0x19e: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/llite/namei.o: ll_test_inode()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/llite/namei.o: ll_test_inode()+0x5: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/llite/namei.o: ll_test_inode()+0x9: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/llite/rw.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/llite/statahead.o: md_revalidate_lock.part.26()+0x0: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/llite/statahead.o: md_revalidate_lock.part.26()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/llite/statahead.o: md_revalidate_lock.part.26()+0x24: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/llite/statahead.o: sa_args_fini()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/llite/statahead.o: sa_args_fini()+0x5: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/llite/statahead.o: sa_args_fini()+0x9: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/llite/statahead.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/llite/vvp_page.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/llite/xattr_cache.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/llite/xattr.o: get_xattr_type()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/llite/xattr.o: get_xattr_type()+0x1f: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/llite/xattr.o: get_xattr_type()+0x5: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/lmv/lmv_intent.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/lmv/lmv_obd.o: __lmv_fid_alloc()+0x185: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/lov/lov_io.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/lov/lovsub_dev.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/mdc/mdc_lib.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/mdc/mdc_locks.o: .text.unlikely: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/obdclass/debug.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/obdclass/genops.o: class_name2dev()+0xc7: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/obdclass/lustre_handles.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/obdclass/obd_config.o: lustre_cfg_string()+0x0: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/obdclass/obd_config.o: lustre_cfg_string()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/obdclass/obd_config.o: lustre_cfg_string()+0x4: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: __client_obd_list_lock()+0x0: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: __client_obd_list_lock()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: __client_obd_list_lock()+0x1: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: osc_extent_search()+0x78: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/osc/osc_cache.o: osc_extent_search()+0x78: return without frame pointer restore
> stacktool: drivers/staging/lustre/lustre/osc/osc_dev.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/osc/osc_page.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/ptlrpc/connection.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/ptlrpc/import.o: deuuidify.constprop.8()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/ptlrpc/import.o: deuuidify.constprop.8()+0x5: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/ptlrpc/import.o: deuuidify.constprop.8()+0x6: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/ptlrpc/llog_net.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_extent.o: ldlm_extent_shift_kms()+0x93: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_lock.o: ldlm_work_bl_ast_lock()+0x156: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_lock.o: ldlm_work_cp_ast_lock()+0xda: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/ptlrpc/nrs.o: nrs_policy_register()+0x0: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/ptlrpc/nrs.o: nrs_policy_register()+0x5: duplicate frame pointer save
> stacktool: drivers/staging/lustre/lustre/ptlrpc/nrs.o: nrs_policy_register()+0x6: duplicate frame pointer setup
> stacktool: drivers/staging/lustre/lustre/ptlrpc/nrs.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/ptlrpc/pack_generic.o: lustre_swab_mgs_nidtbl_entry()+0x89: frame pointer state mismatch
> stacktool: drivers/staging/lustre/lustre/ptlrpc/pack_generic.o: lustre_swab_mgs_nidtbl_entry()+0x89: return without frame pointer restore
> stacktool: drivers/staging/lustre/lustre/ptlrpc/sec_bulk.o: .text: unexpected end of section
> stacktool: drivers/staging/lustre/lustre/ptlrpc/sec_config.o: .text: unexpected end of section

These staging driver issues are caused by stacktool getting confused by
gcc optimizations related to noreturn functions.  I have it on the TODO
list to make the noreturn function detection more intelligent.

> stacktool: fs/mbcache.o: mb_cache_entry_find_first()+0x70: call without frame pointer save/setup
> stacktool: fs/mbcache.o: mb_cache_entry_find_first()+0x92: call without frame pointer save/setup
> stacktool: fs/mbcache.o: mb_cache_entry_free()+0xff: call without frame pointer save/setup
> stacktool: fs/mbcache.o: mb_cache_entry_free()+0xf5: call without frame pointer save/setup
> stacktool: fs/mbcache.o: mb_cache_entry_free()+0x11a: call without frame pointer save/setup
> stacktool: fs/mbcache.o: mb_cache_entry_get()+0x225: call without frame pointer save/setup
> stacktool: kernel/locking/percpu-rwsem.o: percpu_up_read()+0x27: call without frame pointer save/setup
> stacktool: kernel/profile.o: do_profile_hits.isra.5()+0x139: call without frame pointer save/setup
> stacktool: lib/nmi_backtrace.o: nmi_trigger_all_cpu_backtrace()+0x2b6: call without frame pointer save/setup
> stacktool: net/rds/ib_cm.o: rds_ib_cq_comp_handler_recv()+0x58: call without frame pointer save/setup
> stacktool: net/rds/ib_cm.o: rds_ib_cq_comp_handler_send()+0x58: call without frame pointer save/setup
> stacktool: net/rds/ib_recv.o: rds_ib_attempt_ack()+0xc1: call without frame pointer save/setup
> stacktool: net/rds/iw_recv.o: rds_iw_attempt_ack()+0xc1: call without frame pointer save/setup
> stacktool: net/rds/iw_recv.o: rds_iw_recv_cq_comp_handler()+0x55: call without frame pointer save/setup

These are all the same "call ___preempt_schedule" issue from above.
I'll need to look into it to figure out if it's a real bug or if it's a
"feature" we should ignore.

-- 
Josh
