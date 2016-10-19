From: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net: limit a number of namespaces which can be cleaned up
	concurrently
Date: Wed, 19 Oct 2016 11:46:08 -0700
Message-ID: <CANaxB-y0nSGy4OOA28jWzoGXwGQM8N7QBwTSwfved=4_mKhCGg@mail.gmail.com>
References: <1476293579-28582-1-git-send-email-avagin@openvz.org>
	<871szk9rl9.fsf@x220.int.ebiederm.org>
	<20161013204405.GA19836@outlook.office365.com>
	<87k2db39zf.fsf@x220.int.ebiederm.org>
	<20161014212642.GA2005@outlook.office365.com>
	<87eg3hy3fm.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11443f3cf2a0bc053f3c386a
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87eg3hy3fm.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

--001a11443f3cf2a0bc053f3c386a
Content-Type: text/plain; charset=UTF-8

On Sat, Oct 15, 2016 at 9:36 AM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:
>
>> On Thu, Oct 13, 2016 at 10:06:28PM -0500, Eric W. Biederman wrote:
>>> Andrei Vagin <avagin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org> writes:
>>>
>>> > On Thu, Oct 13, 2016 at 10:49:38AM -0500, Eric W. Biederman wrote:
>>> >> Andrei Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:
>>> >>
>>> >> > From: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
>>> >> >
>>> >> > The operation of destroying netns is heavy and it is executed under
>>> >> > net_mutex. If many namespaces are destroyed concurrently, net_mutex can
>>> >> > be locked for a long time. It is impossible to create a new netns during
>>> >> > this period of time.
>>> >>
>>> >> This may be the right approach or at least the right approach to bound
>>> >> net_mutex hold times but I have to take exception to calling network
>>> >> namespace cleanup heavy.
>>> >>
>>> >> The only particularly time consuming operation I have ever found are calls to
>>> >> synchronize_rcu/sycrhonize_sched/synchronize_net.
>>> >
>>> > I booted the kernel with maxcpus=1, in this case these functions work
>>> > very fast and the problem is there any way.
>>> >
>>> > Accoding to perf, we spend a lot of time in kobject_uevent:
>>> >
>>> > -   99.96%     0.00%  kworker/u4:1     [kernel.kallsyms]  [k] unregister_netdevice_many
>>> >    - unregister_netdevice_many
>>> >       - 99.95% rollback_registered_many
>>> >          - 99.64% netdev_unregister_kobject
>>> >             - 33.43% netdev_queue_update_kobjects
>>> >                - 33.40% kobject_put
>>> >                   - kobject_release
>>> >                      + 33.37% kobject_uevent
>>> >                      + 0.03% kobject_del
>>> >                + 0.03% sysfs_remove_group
>>> >             - 33.13% net_rx_queue_update_kobjects
>>> >                - kobject_put
>>> >                - kobject_release
>>> >                   + 33.11% kobject_uevent
>>> >                   + 0.01% kobject_del
>>> >                     0.00% rx_queue_release
>>> >             - 33.08% device_del
>>> >                + 32.75% kobject_uevent
>>> >                + 0.17% device_remove_attrs
>>> >                + 0.07% dpm_sysfs_remove
>>> >                + 0.04% device_remove_class_symlinks
>>> >                + 0.01% kobject_del
>>> >                + 0.01% device_pm_remove
>>> >                + 0.01% sysfs_remove_file_ns
>>> >                + 0.00% klist_del
>>> >                + 0.00% driver_deferred_probe_del
>>> >                  0.00% cleanup_glue_dir.isra.14.part.15
>>> >                  0.00% to_acpi_device_node
>>> >                  0.00% sysfs_remove_group
>>> >               0.00% klist_del
>>> >               0.00% device_remove_attrs
>>> >          + 0.26% call_netdevice_notifiers_info
>>> >          + 0.04% rtmsg_ifinfo_build_skb
>>> >          + 0.01% rtmsg_ifinfo_send
>>> >         0.00% dev_uc_flush
>>> >         0.00% netif_reset_xps_queues_gt
>>> >
>>> > Someone can listen these uevents, so we can't stop sending them without
>>> > breaking backward compatibility. We can try to optimize
>>> > kobject_uevent...
>>>
>>> Oh that is a surprise.  We can definitely skip genenerating uevents for
>>> network namespaces that are exiting because by definition no one can see
>>> those network namespaces.  If a socket existed that could see those
>>> uevents it would hold a reference to the network namespace and as such
>>> the network namespace could not exit.
>>>
>>> That sounds like it is worth investigating a little more deeply.
>>>
>>> I am surprised that allocation and freeing is so heavy we are spending
>>> lots of time doing that.  On the other hand kobj_bcast_filter is very
>>> dumb and very late so I expect something can be moved earlier and make
>>> that code cheaper with the tiniest bit of work.
>>>
>>
>> I'm sorry, I've collected this data for a kernel with debug options
>> (DEBUG_SPINLOCK, PROVE_LOCKING, DEBUG_LIST, etc). If a kernel is
>> compiled without debug options, kobject_uevent becomes less expensive,
>> but still expensive.
>>
>> -   98.64%     0.00%  kworker/u4:2  [kernel.kallsyms]    [k] cleanup_net
>>    - cleanup_net
>>       - 98.54% ops_exit_list.isra.4
>>          - 60.48% default_device_exit_batch
>>             - 60.40% unregister_netdevice_many
>>                - rollback_registered_many
>>                   - 59.82% netdev_unregister_kobject
>>                      - 20.10% device_del
>>                         + 19.44% kobject_uevent
>>                         + 0.40% device_remove_attrs
>>                         + 0.17% dpm_sysfs_remove
>>                         + 0.04% device_remove_class_symlinks
>>                         + 0.04% kobject_del
>>                         + 0.01% device_pm_remove
>>                         + 0.01% sysfs_remove_file_ns
>>                      - 19.89% netdev_queue_update_kobjects
>>                         + 19.81% kobject_put
>>                         + 0.07% sysfs_remove_group
>>                      - 19.79% net_rx_queue_update_kobjects
>>                           kobject_put
>>                         - kobject_release
>>                            + 19.77% kobject_uevent
>>                            + 0.02% kobject_del
>>                              0.01% rx_queue_release
>>                      + 0.02% kset_unregister
>>                        0.01% pm_runtime_set_memalloc_noio
>>                        0.01% bus_remove_device
>>                   + 0.45% call_netdevice_notifiers_info
>>                   + 0.07% rtmsg_ifinfo_build_skb
>>                   + 0.04% rtmsg_ifinfo_send
>>                     0.01% kset_unregister
>>             + 0.07% rtnl_unlock
>>          + 19.27% rpcsec_gss_exit_net
>>          + 5.45% tcp_net_metrics_exit
>>          + 5.31% sunrpc_exit_net
>>          + 3.18% ip6addrlbl_net_exit
>>
>>
>> So after removing kobject_uevent, cleanup_net becomes more than two times faster:
>>
>> 1000 namespaces are cleaned up for 2.8 seconds with uevents, and 1.2 senconds
>> without uevents. I do this experiments with max_cpus=1 to exclude synchronize_rcu.
>>
>> As a summary we can skip generating uevents, but it doesn't solve the original
>> problem. If we want to avoid the limit introduced in this patch, we have
>> to reduce the time for destroing net namespace in dozen times, don't
>> we?
>
> It definitely looks like optimizing kobject_uevent for this case is
> worth while.
>
> I would not mind getting the raw cost of network namespace cleanups
> below 2.8ms or with uevent cleanups 1.2ms.  There is just a lot going on
> for a lot of good reasons in the networking stack so that can be tricky.

>
> The larger issue is that there is a trade off between latency and
> throughput in network namespace destruction.  Consider the case of
> vsftpd.  Which creates a new network namespace for every connection.
> Something like that can wind up with a huge backlog of network
> namespaces to clean up while continually creating more.  The system will
> go OOM if we don't stop and cleanup what we have.
>
> And the batching is very very important for throughput.  So the smallest
> batch size we could really accept is a batch size that does not hurt
> throughput when destroying network namespaces.  Otherwise we will have a
> growing backlog of network namespaces to cleanup and a system that
> eventuallys stops being usable at all.  In that context I think a long
> hold time on net_mutex is preferable to a system that does not work at
> all.
>
> Now I would love to make both the throughput and the latency better I
> would be all in favor of that, but that requires some deep changes to
> the network namespace initialization and cleanup.  Unfortunately I
> haven't stared at the problem enough to know what those changes would
> need to be.  But something where we would not need to serialize network
> namespace cleanup between different network namespaces.  And ideally
> something we could implement incrementally as there is so much
> networking code I don't expect we could verify and change verything
> overnight.

Eric, I get your point. All these sounds reasonable.

And here is another idea about net_mutex.

The longer I look at net_mutex the more it looks like that it can be replaced
on a read-write lock. It protects per-namespace lists of operations, which are
modified only when modules are loaded or unloaded. And the kernel reads
these lists to create or destroy a new network namespace.

Eric and David, what do you think about this idea? Do you have any ideas
why it will not work.

I don't know this code so well to not skip something obvious. The attached
patch shows how it looks like.

If it will works we will be able to create and destroy net namespaces
concurrently.
And even call cleanup_net() from a few threads if we have a big
backlog. It is only
one of steps which may be useful to fix this problem.


>
> That plus in practice the bottleneck has always been the synchronize_rcu
> calls which tend to take at least a millisecond a piece.  Being able
> overlap those synchronize_rcu calls in the common case has reduced
> the time to run the network stack cleanup code by very dramatic amounts.
>
> Right now I am very happy that the network namespace cleanup code is
> working properly.  When I started the network stack cleanup code to
> cleanup network namespaces I found actual functional bugs.  I will be
> even happier if we can figure out how to make it all run fast.
>
> But ultimately we have the net_mutex and the rtnl_lock that serialize
> things on the setup and cleanup paths and to allow creation to proceed
> while cleanup is ongoing we need to find a way to avoid serialization by
> either of those, and I have honestly drawn a blank.
>
> So right now my best suggestion for making things better is to find and
> fix each little piece we can fix.  Until the things are working as best
> we can make them work.  It is not sexy or glamorous or fast but it makes
> things better and is the best that I can see to do.
>
> Eric
>
>
>> Here is a perf report after skipping generating uevents:
>> -   93.27%     0.00%  kworker/u4:1  [kernel.kallsyms]   [k] cleanup_net
>>    - cleanup_net
>>       - 92.97% ops_exit_list.isra.4
>>          - 35.14% rpcsec_gss_exit_net
>>             - gss_svc_shutdown_net
>>                - 17.40% rsc_cache_destroy_net
>>                   + 8.64% cache_unregister_net
>>                   + 8.52% cache_purge
>>                   + 0.22% cache_destroy_net
>>                + 9.00% cache_unregister_net
>>                + 8.49% cache_purge
>>                + 0.15% destroy_use_gss_proxy_proc_entry
>>                + 0.10% cache_destroy_net
>>          - 14.35% tcp_net_metrics_exit
>>             - 7.32% tcp_metrics_flush_all
>>                + 4.86% _raw_spin_unlock_bh
>>                  0.59% __local_bh_enable_ip
>>               6.12% _raw_spin_lock_bh
>>               0.90% _raw_spin_unlock_bh
>>          - 13.08% sunrpc_exit_net
>>             - 6.91% ip_map_cache_destroy
>>                + 3.90% cache_unregister_net
>>                + 2.86% cache_purge
>>                + 0.15% cache_destroy_net
>>             + 5.95% unix_gid_cache_destroy
>>             + 0.12% rpc_pipefs_exit_net
>>             + 0.10% rpc_proc_exit
>>          - 7.35% ip6addrlbl_net_exit
>>             + call_rcu_sched
>>          + 3.34% xfrm_net_exit
>>          + 1.22% ipv6_frags_exit_net
>>          + 1.17% ipv4_frags_exit_net
>>          + 0.78% fib_net_exit
>>          + 0.76% inet6_net_exit
>>          + 0.76% devinet_exit_net
>>          + 0.68% addrconf_exit_net
>>          + 0.63% igmp6_net_exit
>>          + 0.59% ipv4_mib_exit_net
>>          + 0.59% uevent_net_exit
>>
>>> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers

--001a11443f3cf2a0bc053f3c386a
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-RFC-net-convert-net_mutex-into-a-read-write-lock.patch"
Content-Disposition: attachment;
	filename="0001-RFC-net-convert-net_mutex-into-a-read-write-lock.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iuh9jh370

RnJvbSA2ZmIyNTViZWQxYzgyYTI0OTMxNTk1NTAyYThlMzkzMjAwYzdkZDUyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbmRyZWkgVmFnaW4gPGF2YWdpbkBvcGVudnoub3JnPgpEYXRl
OiBTdW4sIDE2IE9jdCAyMDE2IDE3OjE4OjQzIC0wNzAwClN1YmplY3Q6IFtQQVRDSF0gW1JGQ10g
bmV0OiBjb252ZXJ0IG5ldF9tdXRleCBpbnRvIGEgcmVhZC13cml0ZSBsb2NrCgpJdCBwcm90ZWN0
cyBwZXItbmFtZXNwYWNlIGxpc3RzIG9mIG9wZXJhdGlvbnMsIHdoaWNoIGFyZSBtb2RpZmllZCBv
bmx5CndoZW4gbW9kdWxlcyBhcmUgbG9hZGVkIG9yIHVubG9hZGVkLgpBbmQgdGhlIGtlcm5lbCBy
ZWFkcyB0aGVzZSBsaXN0cyB0byBjcmVhdGUgb3IgZGVzdHJveSBhIG5ldyBuZXR3b3JrCm5hbWVz
cGFjZS4KClNpZ25lZC1vZmYtYnk6IEFuZHJlaSBWYWdpbiA8YXZhZ2luQG9wZW52ei5vcmc+Ci0t
LQogaW5jbHVkZS9saW51eC9ydG5ldGxpbmsuaCB8ICAyICstCiBuZXQvY29yZS9uZXRfbmFtZXNw
YWNlLmMgIHwgMzIgKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0KIG5ldC9jb3JlL3J0
bmV0bGluay5jICAgICAgfCAgNCArKy0tCiAzIGZpbGVzIGNoYW5nZWQsIDE5IGluc2VydGlvbnMo
KyksIDE5IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvcnRuZXRsaW5r
LmggYi9pbmNsdWRlL2xpbnV4L3J0bmV0bGluay5oCmluZGV4IDU3ZTU0ODQuLjFhNzgwYTMgMTAw
NjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvcnRuZXRsaW5rLmgKKysrIGIvaW5jbHVkZS9saW51eC9y
dG5ldGxpbmsuaApAQCAtMzAsNyArMzAsNyBAQCBleHRlcm4gaW50IHJ0bmxfdHJ5bG9jayh2b2lk
KTsKIGV4dGVybiBpbnQgcnRubF9pc19sb2NrZWQodm9pZCk7CiAKIGV4dGVybiB3YWl0X3F1ZXVl
X2hlYWRfdCBuZXRkZXZfdW5yZWdpc3RlcmluZ193cTsKLWV4dGVybiBzdHJ1Y3QgbXV0ZXggbmV0
X211dGV4OworZXh0ZXJuIHN0cnVjdCByd19zZW1hcGhvcmUgbmV0X211dGV4OwogCiAjaWZkZWYg
Q09ORklHX1BST1ZFX0xPQ0tJTkcKIGV4dGVybiBib29sIGxvY2tkZXBfcnRubF9pc19oZWxkKHZv
aWQpOwpkaWZmIC0tZ2l0IGEvbmV0L2NvcmUvbmV0X25hbWVzcGFjZS5jIGIvbmV0L2NvcmUvbmV0
X25hbWVzcGFjZS5jCmluZGV4IDk4OTQzNGYuLjgxZGFmY2UgMTAwNjQ0Ci0tLSBhL25ldC9jb3Jl
L25ldF9uYW1lc3BhY2UuYworKysgYi9uZXQvY29yZS9uZXRfbmFtZXNwYWNlLmMKQEAgLTI3LDcg
KzI3LDcgQEAKIAogc3RhdGljIExJU1RfSEVBRChwZXJuZXRfbGlzdCk7CiBzdGF0aWMgc3RydWN0
IGxpc3RfaGVhZCAqZmlyc3RfZGV2aWNlID0gJnBlcm5ldF9saXN0OwotREVGSU5FX01VVEVYKG5l
dF9tdXRleCk7CitERUNMQVJFX1JXU0VNKG5ldF9tdXRleCk7CiAKIExJU1RfSEVBRChuZXRfbmFt
ZXNwYWNlX2xpc3QpOwogRVhQT1JUX1NZTUJPTF9HUEwobmV0X25hbWVzcGFjZV9saXN0KTsKQEAg
LTU5LDcgKzU5LDcgQEAgc3RhdGljIGludCBuZXRfYXNzaWduX2dlbmVyaWMoc3RydWN0IG5ldCAq
bmV0LCBpbnQgaWQsIHZvaWQgKmRhdGEpCiB7CiAJc3RydWN0IG5ldF9nZW5lcmljICpuZywgKm9s
ZF9uZzsKIAotCUJVR19PTighbXV0ZXhfaXNfbG9ja2VkKCZuZXRfbXV0ZXgpKTsKKwlCVUdfT04o
IXJ3c2VtX2lzX2xvY2tlZCgmbmV0X211dGV4KSk7CiAJQlVHX09OKGlkID09IDApOwogCiAJb2xk
X25nID0gcmN1X2RlcmVmZXJlbmNlX3Byb3RlY3RlZChuZXQtPmdlbiwKQEAgLTM3OSw3ICszNzks
NyBAQCBzdHJ1Y3QgbmV0ICpjb3B5X25ldF9ucyh1bnNpZ25lZCBsb25nIGZsYWdzLAogCiAJZ2V0
X3VzZXJfbnModXNlcl9ucyk7CiAKLQltdXRleF9sb2NrKCZuZXRfbXV0ZXgpOworCWRvd25fcmVh
ZCgmbmV0X211dGV4KTsKIAluZXQtPnVjb3VudHMgPSB1Y291bnRzOwogCXJ2ID0gc2V0dXBfbmV0
KG5ldCwgdXNlcl9ucyk7CiAJaWYgKHJ2ID09IDApIHsKQEAgLTM4Nyw3ICszODcsNyBAQCBzdHJ1
Y3QgbmV0ICpjb3B5X25ldF9ucyh1bnNpZ25lZCBsb25nIGZsYWdzLAogCQlsaXN0X2FkZF90YWls
X3JjdSgmbmV0LT5saXN0LCAmbmV0X25hbWVzcGFjZV9saXN0KTsKIAkJcnRubF91bmxvY2soKTsK
IAl9Ci0JbXV0ZXhfdW5sb2NrKCZuZXRfbXV0ZXgpOworCXVwX3JlYWQoJm5ldF9tdXRleCk7CiAJ
aWYgKHJ2IDwgMCkgewogCQlkZWNfbmV0X25hbWVzcGFjZXModWNvdW50cyk7CiAJCXB1dF91c2Vy
X25zKHVzZXJfbnMpOwpAQCAtNDEyLDcgKzQxMiw3IEBAIHN0YXRpYyB2b2lkIGNsZWFudXBfbmV0
KHN0cnVjdCB3b3JrX3N0cnVjdCAqd29yaykKIAlsaXN0X3JlcGxhY2VfaW5pdCgmY2xlYW51cF9s
aXN0LCAmbmV0X2tpbGxfbGlzdCk7CiAJc3Bpbl91bmxvY2tfaXJxKCZjbGVhbnVwX2xpc3RfbG9j
ayk7CiAKLQltdXRleF9sb2NrKCZuZXRfbXV0ZXgpOworCWRvd25fcmVhZCgmbmV0X211dGV4KTsK
IAogCS8qIERvbid0IGxldCBhbnlvbmUgZWxzZSBmaW5kIHVzLiAqLwogCXJ0bmxfbG9jaygpOwpA
QCAtNDUyLDcgKzQ1Miw3IEBAIHN0YXRpYyB2b2lkIGNsZWFudXBfbmV0KHN0cnVjdCB3b3JrX3N0
cnVjdCAqd29yaykKIAlsaXN0X2Zvcl9lYWNoX2VudHJ5X3JldmVyc2Uob3BzLCAmcGVybmV0X2xp
c3QsIGxpc3QpCiAJCW9wc19mcmVlX2xpc3Qob3BzLCAmbmV0X2V4aXRfbGlzdCk7CiAKLQltdXRl
eF91bmxvY2soJm5ldF9tdXRleCk7CisJdXBfcmVhZCgmbmV0X211dGV4KTsKIAogCS8qIEVuc3Vy
ZSB0aGVyZSBhcmUgbm8gb3V0c3RhbmRpbmcgcmN1IGNhbGxiYWNrcyB1c2luZyB0aGlzCiAJICog
bmV0d29yayBuYW1lc3BhY2UuCkBAIC03NjMsNyArNzYzLDcgQEAgc3RhdGljIGludCBfX2luaXQg
bmV0X25zX2luaXQodm9pZCkKIAogCXJjdV9hc3NpZ25fcG9pbnRlcihpbml0X25ldC5nZW4sIG5n
KTsKIAotCW11dGV4X2xvY2soJm5ldF9tdXRleCk7CisJZG93bl9yZWFkKCZuZXRfbXV0ZXgpOwog
CWlmIChzZXR1cF9uZXQoJmluaXRfbmV0LCAmaW5pdF91c2VyX25zKSkKIAkJcGFuaWMoIkNvdWxk
IG5vdCBzZXR1cCB0aGUgaW5pdGlhbCBuZXR3b3JrIG5hbWVzcGFjZSIpOwogCkBAIC03NzMsNyAr
NzczLDcgQEAgc3RhdGljIGludCBfX2luaXQgbmV0X25zX2luaXQodm9pZCkKIAlsaXN0X2FkZF90
YWlsX3JjdSgmaW5pdF9uZXQubGlzdCwgJm5ldF9uYW1lc3BhY2VfbGlzdCk7CiAJcnRubF91bmxv
Y2soKTsKIAotCW11dGV4X3VubG9jaygmbmV0X211dGV4KTsKKwl1cF9yZWFkKCZuZXRfbXV0ZXgp
OwogCiAJcmVnaXN0ZXJfcGVybmV0X3N1YnN5cygmbmV0X25zX29wcyk7CiAKQEAgLTkxMiw5ICs5
MTIsOSBAQCBzdGF0aWMgdm9pZCB1bnJlZ2lzdGVyX3Blcm5ldF9vcGVyYXRpb25zKHN0cnVjdCBw
ZXJuZXRfb3BlcmF0aW9ucyAqb3BzKQogaW50IHJlZ2lzdGVyX3Blcm5ldF9zdWJzeXMoc3RydWN0
IHBlcm5ldF9vcGVyYXRpb25zICpvcHMpCiB7CiAJaW50IGVycm9yOwotCW11dGV4X2xvY2soJm5l
dF9tdXRleCk7CisJZG93bl93cml0ZSgmbmV0X211dGV4KTsKIAllcnJvciA9ICByZWdpc3Rlcl9w
ZXJuZXRfb3BlcmF0aW9ucyhmaXJzdF9kZXZpY2UsIG9wcyk7Ci0JbXV0ZXhfdW5sb2NrKCZuZXRf
bXV0ZXgpOworCXVwX3dyaXRlKCZuZXRfbXV0ZXgpOwogCXJldHVybiBlcnJvcjsKIH0KIEVYUE9S
VF9TWU1CT0xfR1BMKHJlZ2lzdGVyX3Blcm5ldF9zdWJzeXMpOwpAQCAtOTMwLDkgKzkzMCw5IEBA
IEVYUE9SVF9TWU1CT0xfR1BMKHJlZ2lzdGVyX3Blcm5ldF9zdWJzeXMpOwogICovCiB2b2lkIHVu
cmVnaXN0ZXJfcGVybmV0X3N1YnN5cyhzdHJ1Y3QgcGVybmV0X29wZXJhdGlvbnMgKm9wcykKIHsK
LQltdXRleF9sb2NrKCZuZXRfbXV0ZXgpOworCWRvd25fd3JpdGUoJm5ldF9tdXRleCk7CiAJdW5y
ZWdpc3Rlcl9wZXJuZXRfb3BlcmF0aW9ucyhvcHMpOwotCW11dGV4X3VubG9jaygmbmV0X211dGV4
KTsKKwl1cF93cml0ZSgmbmV0X211dGV4KTsKIH0KIEVYUE9SVF9TWU1CT0xfR1BMKHVucmVnaXN0
ZXJfcGVybmV0X3N1YnN5cyk7CiAKQEAgLTk1OCwxMSArOTU4LDExIEBAIEVYUE9SVF9TWU1CT0xf
R1BMKHVucmVnaXN0ZXJfcGVybmV0X3N1YnN5cyk7CiBpbnQgcmVnaXN0ZXJfcGVybmV0X2Rldmlj
ZShzdHJ1Y3QgcGVybmV0X29wZXJhdGlvbnMgKm9wcykKIHsKIAlpbnQgZXJyb3I7Ci0JbXV0ZXhf
bG9jaygmbmV0X211dGV4KTsKKwlkb3duX3dyaXRlKCZuZXRfbXV0ZXgpOwogCWVycm9yID0gcmVn
aXN0ZXJfcGVybmV0X29wZXJhdGlvbnMoJnBlcm5ldF9saXN0LCBvcHMpOwogCWlmICghZXJyb3Ig
JiYgKGZpcnN0X2RldmljZSA9PSAmcGVybmV0X2xpc3QpKQogCQlmaXJzdF9kZXZpY2UgPSAmb3Bz
LT5saXN0OwotCW11dGV4X3VubG9jaygmbmV0X211dGV4KTsKKwl1cF93cml0ZSgmbmV0X211dGV4
KTsKIAlyZXR1cm4gZXJyb3I7CiB9CiBFWFBPUlRfU1lNQk9MX0dQTChyZWdpc3Rlcl9wZXJuZXRf
ZGV2aWNlKTsKQEAgLTk3OCwxMSArOTc4LDExIEBAIEVYUE9SVF9TWU1CT0xfR1BMKHJlZ2lzdGVy
X3Blcm5ldF9kZXZpY2UpOwogICovCiB2b2lkIHVucmVnaXN0ZXJfcGVybmV0X2RldmljZShzdHJ1
Y3QgcGVybmV0X29wZXJhdGlvbnMgKm9wcykKIHsKLQltdXRleF9sb2NrKCZuZXRfbXV0ZXgpOwor
CWRvd25fd3JpdGUoJm5ldF9tdXRleCk7CiAJaWYgKCZvcHMtPmxpc3QgPT0gZmlyc3RfZGV2aWNl
KQogCQlmaXJzdF9kZXZpY2UgPSBmaXJzdF9kZXZpY2UtPm5leHQ7CiAJdW5yZWdpc3Rlcl9wZXJu
ZXRfb3BlcmF0aW9ucyhvcHMpOwotCW11dGV4X3VubG9jaygmbmV0X211dGV4KTsKKwl1cF93cml0
ZSgmbmV0X211dGV4KTsKIH0KIEVYUE9SVF9TWU1CT0xfR1BMKHVucmVnaXN0ZXJfcGVybmV0X2Rl
dmljZSk7CiAKZGlmZiAtLWdpdCBhL25ldC9jb3JlL3J0bmV0bGluay5jIGIvbmV0L2NvcmUvcnRu
ZXRsaW5rLmMKaW5kZXggYjA2ZDJmNC4uNzUzMzQxOSAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvcnRu
ZXRsaW5rLmMKKysrIGIvbmV0L2NvcmUvcnRuZXRsaW5rLmMKQEAgLTQxOCwxMSArNDE4LDExIEBA
IHN0YXRpYyB2b2lkIHJ0bmxfbG9ja191bnJlZ2lzdGVyaW5nX2FsbCh2b2lkKQogdm9pZCBydG5s
X2xpbmtfdW5yZWdpc3RlcihzdHJ1Y3QgcnRubF9saW5rX29wcyAqb3BzKQogewogCS8qIENsb3Nl
IHRoZSByYWNlIHdpdGggY2xlYW51cF9uZXQoKSAqLwotCW11dGV4X2xvY2soJm5ldF9tdXRleCk7
CisJZG93bl93cml0ZSgmbmV0X211dGV4KTsKIAlydG5sX2xvY2tfdW5yZWdpc3RlcmluZ19hbGwo
KTsKIAlfX3J0bmxfbGlua191bnJlZ2lzdGVyKG9wcyk7CiAJcnRubF91bmxvY2soKTsKLQltdXRl
eF91bmxvY2soJm5ldF9tdXRleCk7CisJdXBfd3JpdGUoJm5ldF9tdXRleCk7CiB9CiBFWFBPUlRf
U1lNQk9MX0dQTChydG5sX2xpbmtfdW5yZWdpc3Rlcik7CiAKLS0gCjIuNy40Cgo=
--001a11443f3cf2a0bc053f3c386a
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--001a11443f3cf2a0bc053f3c386a--
