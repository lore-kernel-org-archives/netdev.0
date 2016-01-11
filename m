From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 29/53] perf tools: Make ordered_events reusable
Date: Mon, 11 Jan 2016 18:33:20 -0300
Message-ID: <20160111213320.GH18367@kernel.org>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-30-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	He Kuang <hekuang@huawei.com>, Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: Wang Nan <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452520124-2073-30-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 11, 2016 at 01:48:20PM +0000, Wang Nan escreveu:
> ordered_events__free() leaves linked lists and timestamps not cleared.
> Introduce ordered_events__reset() to reinit ordered_events so it can
> be reused again.

Reused where? Can you mention the usecase?

Do we have to introduce a new function? Why not just make
ordered_events__free() to get the state to what was after
ordered_events__init()?

- Arnaldo
 
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Signed-off-by: He Kuang <hekuang@huawei.com>
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Cc: Jiri Olsa <jolsa@kernel.org>
> Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
> Cc: Namhyung Kim <namhyung@kernel.org>
> Cc: Zefan Li <lizefan@huawei.com>
> Cc: pi3orama@163.com
> ---
>  tools/perf/util/ordered-events.c | 9 +++++++++
>  tools/perf/util/ordered-events.h | 1 +
>  tools/perf/util/session.c        | 4 ++--
>  3 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/perf/util/ordered-events.c b/tools/perf/util/ordered-events.c
> index b1b9e23..81daada 100644
> --- a/tools/perf/util/ordered-events.c
> +++ b/tools/perf/util/ordered-events.c
> @@ -308,3 +308,12 @@ void ordered_events__free(struct ordered_events *oe)
>  		free(event);
>  	}
>  }
> +
> +void ordered_events__reset(struct ordered_events *oe)
> +{
> +	ordered_events__deliver_t old_deliver = oe->deliver;
> +
> +	ordered_events__free(oe);
> +	memset(oe, '\0', sizeof(*oe));
> +	ordered_events__init(oe, old_deliver);
> +}
> diff --git a/tools/perf/util/ordered-events.h b/tools/perf/util/ordered-events.h
> index f403991..77e0f1b 100644
> --- a/tools/perf/util/ordered-events.h
> +++ b/tools/perf/util/ordered-events.h
> @@ -49,6 +49,7 @@ void ordered_events__delete(struct ordered_events *oe, struct ordered_event *eve
>  int ordered_events__flush(struct ordered_events *oe, enum oe_flush how);
>  void ordered_events__init(struct ordered_events *oe, ordered_events__deliver_t deliver);
>  void ordered_events__free(struct ordered_events *oe);
> +void ordered_events__reset(struct ordered_events *oe);
>  
>  static inline
>  void ordered_events__set_alloc_size(struct ordered_events *oe, u64 size)
> diff --git a/tools/perf/util/session.c b/tools/perf/util/session.c
> index d5636ba..96e10d2 100644
> --- a/tools/perf/util/session.c
> +++ b/tools/perf/util/session.c
> @@ -1701,7 +1701,7 @@ done:
>  out_err:
>  	free(buf);
>  	perf_session__warn_about_errors(session);
> -	ordered_events__free(&session->ordered_events);
> +	ordered_events__reset(&session->ordered_events);
>  	auxtrace__free_events(session);
>  	return err;
>  }
> @@ -1857,7 +1857,7 @@ out:
>  out_err:
>  	ui_progress__finish();
>  	perf_session__warn_about_errors(session);
> -	ordered_events__free(&session->ordered_events);
> +	ordered_events__reset(&session->ordered_events);
>  	auxtrace__free_events(session);
>  	session->one_mmap = false;
>  	return err;
> -- 
> 1.8.3.4
