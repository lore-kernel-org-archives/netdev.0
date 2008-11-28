From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 6/6] fs: Introduce kern_mount_special() to mount
	special vfs
Date: Fri, 28 Nov 2008 19:58:54 +0100
Message-ID: <20081128185854.GA19682@elte.hu>
References: <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDCAB.1070204@cosmosbay.com> <20081128092604.GL28946@ZenIV.linux.org.uk> <20081128180220.GK10487@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>, rth@twiddle.net,
	ink@jurassic.park.msu.ru
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:58683 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501AbYK1S7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2008 13:59:32 -0500
Content-Disposition: inline
In-Reply-To: <20081128180220.GK10487@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> And i wouldnt expect it to hurt real-filesystem workloads.
> 
> Here's the contemporary trace of a typical ext3- sys_open():

here's a sys_open() that has to touch atime:

 0)               |  sys_open() {
 0)               |    do_sys_open() {
 0)               |      getname() {
 0)      0.377 us |        kmem_cache_alloc();
 0)               |        strncpy_from_user() {
 0)               |          _cond_resched() {
 0)               |            need_resched() {
 0)      0.353 us |              constant_test_bit();
 0)      1. 45 us |            }
 0)      1.739 us |          }
 0)      2.492 us |        }
 0)      3.934 us |      }
 0)               |      alloc_fd() {
 0)      0.374 us |        _spin_lock();
 0)      0.447 us |        expand_files();
 0)      2.124 us |      }
 0)               |      do_filp_open() {
 0)               |        path_lookup_open() {
 0)               |          get_empty_filp() {
 0)      0.689 us |            kmem_cache_alloc();
 0)               |            security_file_alloc() {
 0)      0.327 us |              cap_file_alloc_security();
 0)      1. 71 us |            }
 0)      2.869 us |          }
 0)               |          do_path_lookup() {
 0)      0.460 us |            _read_lock();
 0)               |            path_walk() {
 0)               |              __link_path_walk() {
 0)               |                inode_permission() {
 0)               |                  ext3_permission() {
 0)      0.434 us |                    generic_permission();
 0)      1.191 us |                  }
 0)               |                  security_inode_permission() {
 0)      0.400 us |                    cap_inode_permission();
 0)      1.130 us |                  }
 0)      3.453 us |                }
 0)               |                do_lookup() {
 0)               |                  __d_lookup() {
 0)      0.489 us |                    _spin_lock();
 0)      1.525 us |                  }
 0)      0.449 us |                  __follow_mount();
 0)      3.115 us |                }
 0)               |                path_to_nameidata() {
 0)      0.422 us |                  dput();
 0)      1.204 us |                }
 0)               |                inode_permission() {
 0)               |                  ext3_permission() {
 0)      0.391 us |                    generic_permission();
 0)      1.223 us |                  }
 0)               |                  security_inode_permission() {
 0)      0.406 us |                    cap_inode_permission();
 0)      1.189 us |                  }
 0)      3.565 us |                }
 0)               |                do_lookup() {
 0)               |                  __d_lookup() {
 0)      0.527 us |                    _spin_lock();
 0)      1.633 us |                  }
 0)      0.440 us |                  __follow_mount();
 0)      3.223 us |                }
 0)               |                do_follow_link() {
 0)               |                  _cond_resched() {
 0)               |                    need_resched() {
 0)      0.361 us |                      constant_test_bit();
 0)      1. 64 us |                    }
 0)      1.749 us |                  }
 0)               |                  security_inode_follow_link() {
 0)      0.390 us |                    cap_inode_follow_link();
 0)      1.260 us |                  }
 0)               |                  touch_atime() {
 0)               |                    mnt_want_write() {
 0)      0.360 us |                      _spin_lock();
 0)      1.137 us |                    }
 0)               |                    mnt_drop_write() {
 0)      0.348 us |                      _spin_lock();
 0)      1.102 us |                    }
 0)      3.402 us |                  }
 0)      0.446 us |                  ext3_follow_link();
 0)               |                  __link_path_walk() {
 0)               |                    inode_permission() {
 0)               |                      ext3_permission() {
 0)               |                        generic_permission() {
 0)      4.481 us |                      }
 0)               |                      security_inode_permission() {
 0)      0.402 us |                        cap_inode_permission();
 0)      1.127 us |                      }
 0)      6.747 us |                    }
 0)               |                    do_lookup() {
 0)               |                      __d_lookup() {
 0)      0.547 us |                        _spin_lock();
 0)      1.758 us |                      }
 0)      0.465 us |                      __follow_mount();
 0)      3.368 us |                    }
 0)               |                    path_to_nameidata() {
 0)      0.419 us |                      dput();
 0)      1.203 us |                    }
 0) +   13. 40 us |                  }
 0)               |                  path_put() {
 0)      0.429 us |                    dput();
 0)               |                    mntput() {
 0)      0.367 us |                      mntput_no_expire();
 0)      1.130 us |                    }
 0)      2.660 us |                  }
 0)               |                  path_put() {
 0)               |                    dput() {
 0)               |                      _cond_resched() {
 0)               |                        need_resched() {
 0)      0.382 us |                          constant_test_bit();
 0)      1. 67 us |                        }
 0)      1.808 us |                      }
 0)      0.399 us |                      _spin_lock();
 0)      0.452 us |                      _spin_lock();
 0)      4.270 us |                    }
 0)               |                    mntput() {
 0)      0.375 us |                      mntput_no_expire();
 0)      1. 62 us |                    }
 0)      6.547 us |                  }
 0) +   32.702 us |                }
 0) +   50.413 us |              }
 0)               |              path_put() {
 0)      0.421 us |                dput();
 0)               |                mntput() {
 0)      0.364 us |                  mntput_no_expire();
 0)      1. 64 us |                }
 0)      2.545 us |              }
 0) +   54.147 us |            }
 0) +   55.780 us |          }
 0) +   59.714 us |        }
 0)               |        may_open() {
 0)               |          inode_permission() {
 0)               |            ext3_permission() {
 0)      0.406 us |              generic_permission();
 0)      1.189 us |            }
 0)               |            security_inode_permission() {
 0)      0.388 us |              cap_inode_permission();
 0)      1.175 us |            }
 0)      3.498 us |          }
 0)      4.328 us |        }
 0)               |        nameidata_to_filp() {
 0)               |          __dentry_open() {
 0)               |            file_move() {
 0)      0.361 us |              _spin_lock();
 0)      1.102 us |            }
 0)               |            security_dentry_open() {
 0)      0.356 us |              cap_dentry_open();
 0)      1.121 us |            }
 0)      0.400 us |            generic_file_open();
 0)      0.544 us |            file_ra_state_init();
 0)      5. 11 us |          }
 0)      5.709 us |        }
 0) +   71.181 us |      }
 0)      0.453 us |      inotify_dentry_parent_queue_event();
 0)      0.403 us |      inotify_inode_queue_event();
 0)               |      fd_install() {
 0)      0.411 us |        _spin_lock();
 0)      1.217 us |      }
 0)               |      putname() {
 0)               |        kmem_cache_free() {
 0)               |          virt_to_head_page() {
 0)      0.371 us |            constant_test_bit();
 0)      1. 47 us |          }
 0)      1.752 us |        }
 0)      2.446 us |      }
 0) +   84.676 us |    }
 0) +   85.365 us |  }

	Ingo
