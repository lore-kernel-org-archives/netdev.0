From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH 6/6] fs: Introduce kern_mount_special() to mount	special
 vfs
Date: Fri, 28 Nov 2008 23:20:24 +0100
Message-ID: <49306EA8.1050801@cosmosbay.com>
References: <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDCAB.1070204@cosmosbay.com> <20081128092604.GL28946@ZenIV.linux.org.uk> <20081128180220.GK10487@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org,
	ink-biIs/Y0ymYJMZLIVYojuPNP0rXTJTi09@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081128180220.GK10487-X9Un+BFzKDI@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ingo Molnar a =E9crit :
> * Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> wrote:
>=20
>> On Thu, Nov 27, 2008 at 12:32:59AM +0100, Eric Dumazet wrote:
>>> This function arms a flag (MNT_SPECIAL) on the vfs, to avoid
>>> refcounting on permanent system vfs.
>>> Use this function for sockets, pipes, anonymous fds.
>> IMO that's pushing it past the point of usefulness; unless you can s=
how
>> that this really gives considerable win on pipes et.al. *AND* that i=
t
>> doesn't hurt other loads...
>=20
> The numbers look pretty convincing:
>=20
>>>  (socket8 bench result : from 2.94s to 2.23s)
>=20
> And i wouldnt expect it to hurt real-filesystem workloads.
>=20
> Here's the contemporary trace of a typical ext3- sys_open():
>=20
>  0)               |  sys_open() {
>  0)               |    do_sys_open() {
>  0)               |      getname() {
>  0)      0.367 us |        kmem_cache_alloc();
>  0)               |        strncpy_from_user(); {
>  0)               |          _cond_resched() {
>  0)               |            need_resched() {
>  0)      0.363 us |              constant_test_bit();
>  0)      1. 47 us |            }
>  0)      1.815 us |          }
>  0)      2.587 us |        }
>  0)      4. 22 us |      }
>  0)               |      alloc_fd() {
>  0)      0.480 us |        _spin_lock();
>  0)      0.487 us |        expand_files();
>  0)      2.356 us |      }
>  0)               |      do_filp_open() {
>  0)               |        path_lookup_open() {
>  0)               |          get_empty_filp() {
>  0)      0.439 us |            kmem_cache_alloc();
>  0)               |            security_file_alloc() {
>  0)      0.316 us |              cap_file_alloc_security();
>  0)      1. 87 us |            }
>  0)      3.189 us |          }
>  0)               |          do_path_lookup() {
>  0)      0.366 us |            _read_lock();
>  0)               |            path_walk() {
>  0)               |              __link_path_walk() {
>  0)               |                inode_permission() {
>  0)               |                  ext3_permission() {
>  0)      0.441 us |                    generic_permission();
>  0)      1.247 us |                  }
>  0)               |                  security_inode_permission() {
>  0)      0.411 us |                    cap_inode_permission();
>  0)      1.186 us |                  }
>  0)      3.555 us |                }
>  0)               |                do_lookup() {
>  0)               |                  __d_lookup() {
>  0)      0.486 us |                    _spin_lock();
>  0)      1.369 us |                  }
>  0)      0.442 us |                  __follow_mount();
>  0)      3. 14 us |                }
>  0)               |                path_to_nameidata() {
>  0)      0.476 us |                  dput();
>  0)      1.235 us |                }
>  0)               |                inode_permission() {
>  0)               |                  ext3_permission() {
>  0)               |                    generic_permission() {
>  0)               |                      in_group_p() {
>  0)      0.410 us |                        groups_search();
>  0)      1.172 us |                      }
>  0)      1.994 us |                    }
>  0)      2.789 us |                  }
>  0)               |                  security_inode_permission() {
>  0)      0.454 us |                    cap_inode_permission();
>  0)      1.238 us |                  }
>  0)      5.262 us |                }
>  0)               |                do_lookup() {
>  0)               |                  __d_lookup() {
>  0)      0.480 us |                    _spin_lock();
>  0)      1.621 us |                  }
>  0)      0.456 us |                  __follow_mount();
>  0)      3.215 us |                }
>  0)               |                path_to_nameidata() {
>  0)      0.420 us |                  dput();
>  0)      1.193 us |                }
>  0) +   23.551 us |              }
>  0)               |              path_put() {
>  0)      0.420 us |                dput();
>  0)               |                mntput() {
>  0)      0.359 us |                  mntput_no_expire();
>  0)      1. 50 us |                }
>  0)      2.544 us |              }
>  0) +   27.253 us |            }
>  0) +   28.850 us |          }
>  0) +   33.217 us |        }
>  0)               |        may_open() {
>  0)               |          inode_permission() {
>  0)               |            ext3_permission() {
>  0)      0.480 us |              generic_permission();
>  0)      1.229 us |            }
>  0)               |            security_inode_permission() {
>  0)      0.405 us |              cap_inode_permission();
>  0)      1.196 us |            }
>  0)      3.589 us |          }
>  0)      4.600 us |        }
>  0)               |        nameidata_to_filp() {
>  0)               |          __dentry_open() {
>  0)               |            file_move() {
>  0)      0.470 us |              _spin_lock();
>  0)      1.243 us |            }
>  0)               |            security_dentry_open() {
>  0)      0.344 us |              cap_dentry_open();
>  0)      1.139 us |            }
>  0)      0.412 us |            generic_file_open();
>  0)      0.561 us |            file_ra_state_init();
>  0)      5.714 us |          }
>  0)      6.483 us |        }
>  0) +   46.494 us |      }
>  0)      0.453 us |      inotify_dentry_parent_queue_event();
>  0)      0.403 us |      inotify_inode_queue_event();
>  0)               |      fd_install() {
>  0)      0.440 us |        _spin_lock();
>  0)      1.247 us |      }
>  0)               |      putname() {
>  0)               |        kmem_cache_free() {
>  0)               |          virt_to_head_page() {
>  0)      0.369 us |            constant_test_bit();
>  0)      1. 23 us |          }
>  0)      1.738 us |        }
>  0)      2.422 us |      }
>  0) +   60.560 us |    }
>  0) +   61.368 us |  }
>=20
> and here's a sys_close():
>=20
>  0)               |  sys_close() {
>  0)      0.540 us |    _spin_lock();
>  0)               |    filp_close() {
>  0)      0.437 us |      dnotify_flush();
>  0)      0.401 us |      locks_remove_posix();
>  0)      0.349 us |      fput();
>  0)      2.679 us |    }
>  0)      4.452 us |  }
>=20
> i'd be surprised to see a flag to show up in that codepath. Eric, doe=
s=20
> your testing confirm that?

On a socket/pipe, definitly no, because inode->i_sb->s_flags is not con=
tended.

But on a shared inode, it might hurt :

offsetof(struct inode, i_count)=3D0x24
offsetof(struct inode, i_lock)=3D0x70
offsetof(struct inode, i_sb)=3D0x9c
offsetof(struct inode, i_writecount)=3D0x144

So i_sb sits in a probably contended cache line=20

I wonder why i_writecount sits so far from i_count, that doesnt make se=
nse.
